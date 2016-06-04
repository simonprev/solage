defmodule SolageQuerySortBuilderTest do
  use ExUnit.Case
  doctest Solage.QuerySortBuilder

  @empty_config %Solage.QueryConfig{}

  test "nil sort" do
    sort = Solage.QuerySortBuilder.build(nil, @empty_config)
    assert sort == []
  end

  test "empty string sort" do
    sort = Solage.QuerySortBuilder.build("", @empty_config)
    assert sort == []
  end

  test "simple sort" do
    sort = Solage.QuerySortBuilder.build("inserted_at", @empty_config)
    assert sort == [asc: :inserted_at]
  end

  test "desc sort" do
    sort = Solage.QuerySortBuilder.build("-inserted_at", @empty_config)
    assert sort == [desc: :inserted_at]
  end

  test "multiple sort" do
    sort = Solage.QuerySortBuilder.build("description,-inserted_at", @empty_config)
    assert sort == [asc: :description, desc: :inserted_at]
  end

  test "allowed sort" do
    config = %{@empty_config | options: [allowed_sort: ~w(inserted_at)]}

    sort = Solage.QuerySortBuilder.build("description,-inserted_at", config)
    assert sort == [desc: :inserted_at]
  end
end
