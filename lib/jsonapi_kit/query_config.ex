defmodule JsonapiKit.QueryConfig do
  @moduledoc """
  Used everwhere to have declarative data structures to map and restrict input query.

  The config is initialized in the `JsonapiKit.Query` plug and is passed all the way
  to the module `render/4` function that outputs data.
  """
  @type t :: %__MODULE__{}

  defstruct include: [], sort: [], filter: %{}, fields: %{}, options: []
end
