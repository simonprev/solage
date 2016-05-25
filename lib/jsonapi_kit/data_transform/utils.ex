defmodule JsonapiKit.DataTransform.Utils do
  @decode_formatter Application.get_env(:jsonapi_kit, :decode_formatter, :dasherized)
  @encode_formatter Application.get_env(:jsonapi_kit, :encode_formatter, :dasherized)

  def decode_key(key), do: process(key, @decode_formatter, :decode_key)
  def encode_key(key), do: process(key, @encode_formatter, :encode_key)

  defp process(key, formatter, function) do
    case formatter do
      :dasherized -> apply(JsonapiKit.DataTransform.Dasherized, function, [key])
      module when is_atom(module) -> apply(module, function, [key])
      _ -> key
    end
  end
end
