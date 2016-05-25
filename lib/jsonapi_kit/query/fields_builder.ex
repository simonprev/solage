defmodule JsonapiKit.QueryFieldsBuilder do
  @moduledoc """
  Parse the `fields` param to return a sane representation of all the available fields.

  The representation looks like this.

  ```
  %{
    "user" => ["id", "name", "email"]
  }
  ```

  It can also reject unallowed fields.
  If the `allowed_fields` options is not passed, that means that every field is allowed.

  ## Examples

  ```
  # With no options
  iex> JsonapiKit.QueryFieldsBuilder.build(%{"user" => "id,name"}, %JsonapiKit.QueryConfig{})
  %{"user" => ["id", "name"]}

  # With allowed fields option
  iex> JsonapiKit.QueryFieldsBuilder.build(%{"user" => "id,name,password"}, %JsonapiKit.QueryConfig{options: [allowed_fields: %{"user" => ~w(id name email)}]})
  %{"user" => ["id", "name"]}

  ```
  """

  @behaviour JsonapiKit.QueryBuilder

  @field_separator ","

  def build(nil, _config), do: []
  def build("", _config), do: []
  def build(param, config) do
    param
    |> Enum.reduce(%{}, &(parse_field(&1, &2, config)))
  end

  defp parse_field({type, value}, acc, config) do
    filtered_value = value
    |> String.split(@field_separator)
    |> reject_unallowed_fields(type, config)

    Map.put(acc, type, filtered_value)
  end

  defp reject_unallowed_fields(items, type, config) do
    case config.options[:allowed_fields] do
      nil -> items
      allowed_fields ->
        items
        |> Enum.reject(fn(item) ->
            not Enum.member?(allowed_fields[type], item)
        end)
    end
  end
end
