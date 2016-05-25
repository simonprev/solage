defmodule JsonapiKitQuerySortBuilderTest do
  use ExUnit.Case
  doctest JsonapiKit.QuerySortBuilder

  @empty_config %JsonapiKit.QueryConfig{}

  test "nil sort" do
    sort = JsonapiKit.QuerySortBuilder.build(nil, @empty_config)
    assert sort == []
  end

  test "empty string sort" do
    sort = JsonapiKit.QuerySortBuilder.build("", @empty_config)
    assert sort == []
  end

  test "simple sort" do
    sort = JsonapiKit.QuerySortBuilder.build("inserted_at", @empty_config)
    assert sort == [asc: :inserted_at]
  end

  test "desc sort" do
    sort = JsonapiKit.QuerySortBuilder.build("-inserted_at", @empty_config)
    assert sort == [desc: :inserted_at]
  end

  test "multiple sort" do
    sort = JsonapiKit.QuerySortBuilder.build("description,-inserted_at", @empty_config)
    assert sort == [asc: :description, desc: :inserted_at]
  end

  test "allowed sort" do
    config = %{@empty_config | options: [allowed_sort: ~w(inserted_at)]}

    sort = JsonapiKit.QuerySortBuilder.build("description,-inserted_at", config)
    assert sort == [desc: :inserted_at]
  end
end
