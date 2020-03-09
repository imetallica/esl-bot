defmodule Integrations.Datatypes.Issue do
  alias Integrations.Datatypes.User
  alias Integrations.Datatypes.Repository

  @enforce_keys [:reporter, :id, :title, :repository, :created_at, :state]
  defstruct reporter: %User{id: nil},
            assignees: [],
            id: nil,
            created_at: nil,
            last_updated_at: nil,
            title: nil,
            closed_at: nil,
            state: nil,
            repository: %Repository{name: nil, owner: nil}

  @type t :: %__MODULE__{}
end
