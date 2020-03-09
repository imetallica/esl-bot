defmodule Integrations.Adapters.Github do
  @moduledoc """
  The implementation of adapter behaviour, but for Github.
  """
  alias Integrations.Adapters.Github.Client
  alias Integrations.Datatypes.User
  alias Integrations.Datatypes.Repository
  alias Integrations.Datatypes.Issue
  alias Integrations.Datatypes.PullRequest
  require Logger

  @behaviour Integrations.Adapter

  defguard is_not_nil(term) when not is_nil(term)
  defguard both_are_not_nil(left, right) when is_not_nil(left) and is_not_nil(right)

  def list_issues(organization, project)
      when is_binary(organization) and is_binary(project) do
    case Client.get_all_paginated("/repos/#{organization}/#{project}/issues", state: "all") do
      {:ok, issues} ->
        Enum.reduce_while(issues, [], fn issue, acc ->
          case from_raw_issue_to_native_issue(issue) do
            {:ok, issue} ->
              {:cont, acc ++ [issue]}

            {:error, reason} ->
              Logger.error(fn -> "Error on Github's data payload. Reason: #{inspect(reason)}." end)

              {:halt, []}
          end
        end)

      {:error, reason} ->
        Logger.error(fn -> "Error on Github's client. Reason: #{inspect(reason)}." end)
        []
    end
  end

  def list_pull_requests(organization, project)
      when is_binary(organization) and is_binary(project) do
    case Client.get_all_paginated("/repos/#{organization}/#{project}/pulls", state: "all") do
      {:ok, pull_requests} ->
        Enum.reduce_while(pull_requests, [], fn pull_request, acc ->
          case from_raw_pull_request_to_native_pull_request(pull_request) do
            {:ok, pull_request} ->
              {:cont, acc ++ [pull_request]}

            {:error, reason} ->
              Logger.error(fn -> "Error on Github's data payload. Reason: #{inspect(reason)}." end)

              {:halt, []}
          end
        end)

      {:error, reason} ->
        Logger.error(fn -> "Error on Github's client. Reason: #{inspect(reason)}." end)
        []
    end
  end

  defp from_raw_user_to_native_user(user) when is_map(user) do
    with id when is_not_nil(id) <- user["id"],
         handle when is_not_nil(handle) <- user["login"] do
      {:ok, %User{id: user["id"], handle: user["login"], fullname: user["name"]}}
    else
      _ ->
        {:error, "Invalid user"}
    end
  end

  defp from_raw_issue_to_native_issue(issue) when is_map(issue) do
    with id when is_not_nil(id) <- issue["number"],
         state when is_not_nil(state) <- issue["state"],
         title when is_not_nil(title) <- issue["title"],
         {:ok, created_at, _} <- DateTime.from_iso8601(issue["created_at"]),
         {:ok, last_updated_at, _} <- from_raw_optional_datetime_to_datetime(issue["updated_at"]),
         {:ok, closed_at, _} <- from_raw_optional_datetime_to_datetime(issue["closed_at"]),
         {:ok, reporter} <-
           from_raw_user_to_native_user(issue["user"]),
         {:ok, repository} <- from_repository_url_to_native_repository(issue["repository_url"]) do
      {:ok,
       %Issue{
         id: id,
         reporter: reporter,
         repository: repository,
         title: title,
         created_at: created_at,
         last_updated_at: last_updated_at,
         state: state,
         closed_at: closed_at
       }}
    end
  end

  defp from_raw_pull_request_to_native_pull_request(pr) when is_map(pr) do
    with id when is_not_nil(id) <- pr["number"],
         state when is_not_nil(state) <- pr["state"],
         locked when is_not_nil(locked) <- pr["locked"],
         title when is_not_nil(title) <- pr["title"],
         {:ok, created_at, _} <-
           from_raw_optional_datetime_to_datetime(pr["created_at"]),
         {:ok, last_updated_at, _} <-
           from_raw_optional_datetime_to_datetime(pr["updated_at"]),
         {:ok, closed_at, _} <-
           from_raw_optional_datetime_to_datetime(pr["closed_at"]),
         {:ok, %User{} = owner} <- from_raw_user_to_native_user(pr["user"]),
         {:ok, %Repository{} = repository} <- from_raw_repo_to_native_repo(pr["base"]) do
      {:ok,
       %PullRequest{
         id: id,
         state: state,
         title: title,
         locked: locked,
         owner: owner,
         repository: repository,
         created_at: created_at,
         last_updated_at: last_updated_at,
         closed_at: closed_at
       }}
    else
      _ -> {:error, "Invalid pull request"}
    end
  end

  defp from_raw_repo_to_native_repo(base) when is_map(base) do
    with owner when is_not_nil(owner) <- base["repo"]["owner"]["login"],
         name when is_not_nil(name) <- base["repo"]["name"] do
      {:ok, %Repository{owner: owner, name: name}}
    end
  end

  defp from_repository_url_to_native_repository(url) when is_binary(url) do
    with [owner, name] when both_are_not_nil(owner, name) <- do_parse_repository_url(url) do
      {:ok, %Repository{owner: owner, name: name}}
    else
      _ -> {:error, "Invalid repository URL."}
    end
  end

  defp do_parse_repository_url(url),
    do: url |> String.split("/repos/") |> List.last() |> String.split("/")

  defp from_raw_optional_datetime_to_datetime(nil), do: {:ok, nil, ""}
  defp from_raw_optional_datetime_to_datetime(dt), do: DateTime.from_iso8601(dt)
end
