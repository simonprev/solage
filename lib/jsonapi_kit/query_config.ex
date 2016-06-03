defmodule JsonapiKit.QueryConfig do
  @type t :: %__MODULE__{}

  defstruct include: [], sort: [], filter: %{}, fields: %{}, options: []
end
