defmodule Solage.DataTransform.Dasherized do
  @moduledoc """
  Implementation of the decoder and encoder for dasherized client keys.
  """

  @behaviour Solage.DataTransform.Transformer

  def decode_key(key) when is_atom(key), do: decode_key(to_string(key))
  def decode_key(key) when is_binary(key), do: String.replace(key, "-", "_")
  def decode_key(key), do: key

  def encode_key(key) when is_atom(key), do: encode_key(to_string(key))
  def encode_key(key) when is_binary(key), do: String.replace(key, "_", "-")
  def encode_key(key), do: key
end
