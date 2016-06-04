defmodule Solage.QuerySortBuilder do
  @moduledoc """
  Parse the `sort` param to return a sane representation of all the sort.

  The representation looks like this and is meant to be understood by the Ecto library.

  ```
  [desc: :field1, asc: :field2]
  ```

  It can also reject unallowed sort.
  If the `allowed_sort` options is not passed, that means that every sort is allowed.

  ## Examples

  ```
  # With no options
  iex> Solage.QuerySortBuilder.build("inserted_at,description", %Solage.QueryConfig{})
  [asc: :inserted_at, asc: :description]

  # With allowed sort option
  iex> Solage.QuerySortBuilder.build("inserted_at,description", %Solage.QueryConfig{options: [allowed_sort: ~w(description)]})
  [asc: :description]

  ```
  """

  @behaviour Solage.QueryBuilder

  @sort_separator ","

  def build(nil, _config), do: []
  def build("", _config), do: []
  def build(param, config) do
    param
    |> String.split(@sort_separator)
    |> reject_unallowed_sort(config)
    |> Enum.map(&parse_sort/1)
  end

  defp parse_sort("-" <> attribute), do: {:desc, String.to_atom(attribute)}
  defp parse_sort(attribute), do: {:asc, String.to_atom(attribute)}

  defp reject_unallowed_sort(items, config) do
    case config.options[:allowed_sort] do
      nil -> items
      allowed_sort ->
        items
        |> Enum.reject(fn
          ("-" <> item) ->
            not Enum.member?(allowed_sort, item)
          item ->
            not Enum.member?(allowed_sort, item)
        end)
    end
  end
end
