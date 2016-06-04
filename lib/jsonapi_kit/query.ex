defmodule Solage.Query do
  @moduledoc """
  Using the available builders, fill the config with the parsed values.

  Supported builders:

  - Include
  - Sort
  - Filter

  The goal of those builder is to parse the `params` sent to the Plug and returned useful
  data structures so that you can use the resulting `jsonapi_query` assign to perform things
  like association preloading or query sorting in Ecto.
  """

  use Plug.Builder

  alias Solage.{
    QueryIncludeBuilder,
    QuerySortBuilder,
    QueryFilterBuilder,
    QueryFieldsBuilder
  }

  plug :parse_includes
  plug :parse_sort
  plug :parse_filters
  plug :parse_fields

  def call(conn, opts) do
    conn
    |> assign(:jsonapi_query, %Solage.QueryConfig{options: opts})
    |> super([])
  end

  defp parse_includes(conn = %Plug.Conn{assigns: %{jsonapi_query: jsonapi_query}}, _) do
    include = QueryIncludeBuilder.build(conn.params["include"], jsonapi_query)
    jsonapi_query = %{jsonapi_query | include: include}

    assign(conn, :jsonapi_query, jsonapi_query)
  end

  defp parse_sort(conn = %Plug.Conn{assigns: %{jsonapi_query: jsonapi_query}}, _) do
    sort = QuerySortBuilder.build(conn.params["sort"], jsonapi_query)
    jsonapi_query = %{jsonapi_query | sort: sort}

    assign(conn, :jsonapi_query, jsonapi_query)
  end

  defp parse_filters(conn = %Plug.Conn{assigns: %{jsonapi_query: jsonapi_query}}, _) do
    filter = QueryFilterBuilder.build(conn.params["filter"], jsonapi_query)
    jsonapi_query = %{jsonapi_query | filter: filter}

    assign(conn, :jsonapi_query, jsonapi_query)
  end

  defp parse_fields(conn = %Plug.Conn{assigns: %{jsonapi_query: jsonapi_query}}, _) do
    fields = QueryFieldsBuilder.build(conn.params["fields"], jsonapi_query)
    jsonapi_query = %{jsonapi_query | fields: fields}

    assign(conn, :jsonapi_query, jsonapi_query)
  end
end
