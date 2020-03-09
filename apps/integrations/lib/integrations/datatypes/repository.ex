defmodule Integrations.Datatypes.Repository do
  @enforce_keys [:name, :owner]
  defstruct name: nil, owner: nil

  @type t :: %__MODULE__{}
end
