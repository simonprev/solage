defmodule Solage.DataTransform.Transformer do
  @moduledoc """
  Behaviour declaration of `DataTransform` modules used in `DataTransform.Utils`.
  """

  @callback decode_key(String.t) :: String.t
  @callback encode_key(String.t) :: String.t
end
