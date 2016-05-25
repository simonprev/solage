defmodule JsonapiKit.AttributeTransform do
  @moduledoc """
  Transforms JSON API compliant data from a client to a useful data structure.

  By default it uses the `Simple` transformer that makes assumptions for the relationships.

  ## Example

  iex> JsonapiKit.AttributeTransform.decode(%{
  ...>   "type" => "post",
  ...>   "attributes" => %{
  ...>     "name" => "Testy"
  ...>   },
  ...>   "relationships" => %{
  ...>     "user" => %{
  ...>       "data" => %{
  ...>         "id" => "1"
  ...>       }
  ...>     }
  ...>   }
  ...> })
  %{
    "post" => %{
      "name" => "Testy",
      "user_id" => "1"
    }
  }
  """
  @transformer Application.get_env(:jsonapi_kit, :attribute_transformer, :simple)

  @spec decode(any) :: map | list
  def decode(data) when is_list(data), do: Enum.map(data, &decode/1)
  def decode(data = %{"type" => type}) do
    data = do_decode(data)
    put_in(%{type => %{}}, [type], data)
  end
  def decode(data) when is_map(data), do: do_decode(data)
  def decode(_), do: %{}

  defp do_decode(data) do
    new_data = Enum.reduce(data, %{}, fn({section, attributes}, acc) ->
      Map.merge(acc, decode_section(section, attributes))
    end)

    if (data["id"]) do
      Map.put(new_data, :id, data["id"])
    else
      new_data
    end
  end

  defp decode_section(section, attributes) do
    case @transformer do
      :simple -> JsonapiKit.AttributeTransform.Simple.decode(section, attributes)
      module when is_atom(module) -> apply(module, :decode, [section, attributes])
      _ -> %{section => attributes}
    end
  end
end
