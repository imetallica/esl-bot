defmodule Integrations.Adapter do
  alias Integrations.Datatypes.Issue

  @callback list_issues(organization :: String.t(), project :: String.t()) :: list(Issue.t())
  @callback list_pull_requests(organization :: String.t(), project :: String.t()) ::
              list(PullRequest.t())
end
