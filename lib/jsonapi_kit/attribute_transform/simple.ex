defmodule JsonapiKit.AttributeTransform.Simple do
  @moduledoc """
  Full of assumptions but ok to get the job done. Referer to JsonapiKit.AttributeTransform module doc
  to see examples of this implementation.
  """

  @behaviour JsonapiKit.AttributeTransform.Transformer

  def decode("attributes", attributes) when is_map(attributes), do: attributes
  def decode("relationships", relationships) when is_map(relationships) do
    Enum.reduce(relationships, %{}, fn
      ({name, %{"data" => %{"id" => id}}}, acc) ->
        Map.put(acc, "#{name}_id", id)
      ({name, %{"data" => ids}}, acc) when is_list(ids) ->
        Map.put(acc, "#{name}_ids", Enum.map(ids, &(&1["id"])))
      (_, acc) -> acc
    end)
  end
  def decode(_unsupported_section, _), do: %{}
end
