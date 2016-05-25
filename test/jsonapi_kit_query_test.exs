defmodule JsonapiKit.QueryTest do
  use ExUnit.Case
  use Plug.Test

  test "sort, include and filter query builder" do
    params = "filter[user]=12&sort=-inserted_at&include=user"
    opts = []

    %Plug.Conn{assigns: %{jsonapi_query: query}} = conn(:get, "/foo?#{params}")
    |> Plug.Conn.fetch_query_params
    |> JsonapiKit.Query.call(JsonapiKit.Query.init(opts))

    assert query.filter == %{"user" => "12"}
    assert query.sort == [desc: :inserted_at]
    assert query.include == [:user]
  end
end
