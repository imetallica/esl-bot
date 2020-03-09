defmodule Integrations.Datatypes.User do
  @enforce_keys [:id]
  defstruct id: nil, handle: nil, fullname: nil

  @type t :: %__MODULE__{}
end
