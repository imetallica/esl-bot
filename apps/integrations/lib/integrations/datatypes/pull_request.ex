defmodule Integrations.Datatypes.PullRequest do
  alias Integrations.Datatypes.Repository
  alias Integrations.Datatypes.User

  @enforce_keys [:id]
  defstruct id: nil,
            repository: %Repository{name: nil, owner: nil},
            reviewers: [],
            owner: %User{id: nil},
            linked_issues: []

  @type t :: %__MODULE__{}
end
