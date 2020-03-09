defmodule Integrations.Datatypes.PullRequest do
  alias Integrations.Datatypes.Repository
  alias Integrations.Datatypes.User

  @enforce_keys [:id, :state, :title, :created_at, :last_updated_at, :closed_at]
  defstruct id: nil,
            repository: %Repository{name: nil, owner: nil},
            reviewers: [],
            title: nil,
            owner: %User{id: nil},
            state: nil,
            created_at: nil,
            last_updated_at: nil,
            closed_at: nil,
            locked: false,
            linked_issues: []

  @type t :: %__MODULE__{}
end
