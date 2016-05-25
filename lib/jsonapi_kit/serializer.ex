defmodule JsonapiKit.Serializer do
  @moduledoc """
  Everything needed to serialize data and includes.

  This makes few assumptions:

  ## The render of the data structure is entirely in the client code.

  We don’t implement the typical keys for a JSON API response. Rendering of the `type`, `id`, `attributes`
  or `relationships` is the responsability of the client. This provides a powerful way
  to implement features such as sparse fields.

  By passing an optional `Plug.Conn` to the `render` function, we can implement
  custom relationships links with no weird DSL forced by the module.

  ## Only 2 functions required

  By providing a module with a `render/3` function and the necessary
  `relation_view/1` functions, we can have the results of what will be in a standard
  JSON API response for the `data` and `included` keys.


  ## Examples

  Views:
  ```
  defmodule PostView do
    def render(data, _config, _conn) do
      %{
        id: data["id"],
        relationships: %{
          user: data["author_id"]
        }
      }
    end

    def relation_view(:author), do: UserView
  end

  defmodule UserView do
    def render(data, _config, _conn) do
      %{
        id: data["id"],
        name: data["fullname"]
      }
    end
  end
  ```

  Endpoint:
  ```
  def show(conn, _) do
    data = JsonapiKit.Serializer.data(PostView, conn.assigns[:post], conn.assigns[:jsonapi_query], conn)
    included = JsonapiKit.Serializer.included(PostView, conn.assigns[:post], conn.assigns[:jsonapi_query], conn)

    json(conn, 200, %{data: data, included: included})
  end
  ```

  Response:
  ```
  {
    "included": [
      {
        "id": "my-author-id",
        "name": "Testy"
      }
    ],
    "data": [
      {
        "id": "my-post-id",
        "relationships": {
          "author": "my-author-id"
        }
    ]
  }
  ```
  """

  @typep serializable :: list | map
  @typep config :: JsonapiKit.QueryConfig.t
  @typep optional_conn :: Plug.Conn.t | nil

  @doc """
  Proxy for the render call on the view module.
  """
  @spec data(atom, serializable, config, optional_conn) :: list
  def data(view, data, config, conn \\ nil)
  def data(view, data, config, conn) when is_map(data), do: [view.render(data, config, conn)]
  def data(view, data, config, conn) when is_list(data) do
    Enum.map(data, &(data(view, &1, config, conn)))
    |> List.flatten
  end

  @doc """
  Recursively get include data from the JsonapiKit.QueryConfig `include` option.

  If you’re using Ecto as the data, you will need the preload the assocations present
  in the `include` option.
  """
  @spec included(atom, serializable, config, optional_conn) :: list
  def included(view, data, config, conn \\ nil) do
    Enum.reduce(config.include, MapSet.new, fn(include, acc) ->
      handle_include(view, data, include, config, conn)
      |> Enum.reduce(acc, &(MapSet.put(&2, &1)))
    end)
    |> MapSet.to_list
  end

  defp handle_include(view, data, include, config, conn) when is_list(data) do
    Enum.map(data, &(handle_include(view, &1, include, config, conn)))
    |> List.flatten
  end

  defp handle_include(view, data, {attribute, rest}, config, conn) do
    {new_data, new_view} = get_data_view(view, data, attribute)

    handle_include(new_view, new_data, rest, config, conn)
  end

  defp handle_include(view, data, attribute, config, conn) do
    {new_data, new_view} = get_data_view(view, data, attribute)

    data(new_view, new_data, config, conn)
  end

  defp get_data_view(view, data, attribute) do
    { Map.get(data, attribute), view.relation_view(attribute) }
  end
end
