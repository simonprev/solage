defmodule Solage.QueryIncludeBuilder do
  @moduledoc """
  Parse the `include` param to return a sane representation of all the includes.

  The representation looks like this and is meant to be understood by the Ecto library.

  ```
  [:model1, {:model1, :nested_assocation}, :model2]
  ```

  It can also reject unallowed includes and add always included params.
  If the `allowed_includes` options is not passed, that means that every include is allowed.

  ## Examples

  ```
  # With allowed includes option
  iex> Solage.QueryIncludeBuilder.build("user,post", %Solage.QueryConfig{options: [allowed_includes: ~w(user)]})
  [:user]

  # With always includes option
  iex> Solage.QueryIncludeBuilder.build("user", %Solage.QueryConfig{options: [always_includes: ~w(post)]})
  [:user, :post]

  # Nested results
  iex> Solage.QueryIncludeBuilder.build("user,user.post", %Solage.QueryConfig{})
  [:user, {:user, :post}]

  ```
  """

  @behaviour Solage.QueryBuilder

  @include_separator ","
  @nested_separator "."

  def build(nil, _opts), do: []
  def build("", _opts), do: []
  def build(param, config) do
    param
    |> String.split(@include_separator)
    |> reject_unallowed_includes(config)
    |> add_always_includes(config)
    |> Enum.map(&handle_nested_include/1)
    |> List.flatten
  end

  defp handle_nested_include(key) do
    [item | path] = key
    |> String.split(@nested_separator)
    |> Enum.map(&String.to_existing_atom/1)
    |> Enum.reverse

    put_as_tree([], path, item)
  end

  defp put_as_tree(_acc, [], val), do: [val]
  defp put_as_tree(acc, [head | tail], val) do
    build_tree(Keyword.put(acc, head, val), tail)
  end

  defp build_tree(acc, []), do: acc
  defp build_tree(acc, [head | tail]) do
    build_tree(Keyword.put([], head, acc), tail)
  end

  defp reject_unallowed_includes(items, config) do
    case config.options[:allowed_includes] do
      nil -> items
      allowed_includes ->
        items
        |> Enum.reject(fn(item) -> not Enum.member?(allowed_includes, item) end)
    end
  end

  defp add_always_includes(items, config) do
    case config.options[:always_includes] do
      nil -> items
      always_includes -> items ++ always_includes
    end
  end
end
