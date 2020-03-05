defmodule Integrations.Datatypes.PullRequest do
  alias Integrations.Datatypes.Repository
  alias Integrations.Datatypes.User

  @enforce_keys [:id, :state, :title]
  defstruct id: nil,
            repository: %Repository{name: nil, owner: nil},
            reviewers: [],
            title: nil,
            owner: %User{id: nil},
            state: nil,
            locked: false,
            linked_issues: []

  @type t :: %__MODULE__{}
end
