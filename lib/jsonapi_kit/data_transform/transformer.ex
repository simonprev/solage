defmodule JsonapiKit.DataTransform.Transformer do
  @callback decode_key(String.t) :: String.t
  @callback encode_key(String.t) :: String.t
end
