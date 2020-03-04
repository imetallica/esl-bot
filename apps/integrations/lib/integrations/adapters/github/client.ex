defmodule Integrations.Adapters.Github.Client do
  use HTTPoison.Base

  defguardp is_not_an_empty_list(list) when is_list(list) and length(list) > 0

  @endpoint "https://api.github.com"

  def process_url(url), do: @endpoint <> url

  @spec get_all_paginated(String.t(), list()) :: {:error, any} | {:ok, []} | {:ok, list(map())}
  def get_all_paginated(url, headers \\ []) do
    do_get_next(url, headers)
  end

  defp do_get_next(url, headers, page \\ 1, acc \\ []) do
    with {:get_step, {:ok, %HTTPoison.Response{status_code: 200, body: body}}} <-
           {:get_step, get(url <> "?page=#{page}", headers)},
         {:decode_and_check_emptiness, {:ok, contents}} when is_not_an_empty_list(contents) <-
           {:decode_and_check_emptiness, Jason.decode(body)} do
      do_get_next(url, headers, page + 1, acc ++ contents)
    else
      {:get_step, _} ->
        {:error, "Cannot query github."}

      {:decode_and_check_emptiness, {:ok, []}} ->
        {:ok, acc}

      {:decode_and_check_emptiness, {:ok, _}} ->
        {:error, "Github payload with wrong format."}

      {:decode_and_check_emptiness, {:error, term}} ->
        {:error, term}
    end
  end
end
