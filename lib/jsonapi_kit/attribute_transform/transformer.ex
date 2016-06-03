defmodule JsonapiKit.AttributeTransform.Transformer do
  @callback decode(String.t, map) :: map
end
