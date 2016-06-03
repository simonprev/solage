defmodule JsonapiKit.AttributeTransform.Transformer do
  @moduledoc """
  Behaviour declaration of `AttributeTransform` modules used in `AttributeTransform` main module.
  """

  @callback decode(String.t, map) :: map
end
