defmodule Solage.QueryBuilder do
  @moduledoc """
  Simple behaviour for module building a data structure from an HTTP handler param.

  Since the HTTP handler can parse Map and List, `build/2` can receive either a
  Map, a List or a simple String
  """

  @typep param :: String.t | map | list

  alias Solage.QueryConfig

  @callback build(param, QueryConfig.t) :: any
end
