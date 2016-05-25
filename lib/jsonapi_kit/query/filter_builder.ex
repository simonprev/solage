defmodule JsonapiKit.QueryFilterBuilder do
  @moduledoc """
  Parse the `filter` param to return a map.

  It can also reject unallowed filter.

  ## Examples

  ```
  # With no options
  iex> JsonapiKit.QueryFilterBuilder.build(%{"user_id" => "1"}, %JsonapiKit.QueryConfig{})
  %{"user_id" => "1"}

  # With allowed filters
  iex> JsonapiKit.QueryFilterBuilder.build(%{"user_id" => "1", "password" => "test"}, %JsonapiKit.QueryConfig{options: [allowed_filters: ~w(user_id)]})
  %{"user_id" => "1"}

  ```
  """

  @behaviour JsonapiKit.QueryBuilder

  def build(param, _config) when not is_map(param), do: %{}
  def build(param, config) do
    param
    |> reject_unallowed_filters(config)
    |> to_map
  end

  defp reject_unallowed_filters(items, config) do
    case config.options[:allowed_filters] do
      nil -> items
      allowed_filters ->
        items
        |> Enum.reject(fn({key, _value}) -> not Enum.member?(allowed_filters, key) end)
    end
  end

  defp to_map(items) do
    Enum.reduce(items, %{}, fn({key, value}, acc) ->
      Map.put(acc, key, value)
    end)
  end
end
