defmodule JsonapiKit.DataTransform.Dasherized do
  @behaviour JsonapiKit.DataTransform.Transformer

  def decode_key(key), do: String.replace(key, "-", "_")
  def encode_key(key), do: String.replace(key, "_", "-")
end
