defmodule SolageQueryFilterBuilderTest do
  use ExUnit.Case
  doctest Solage.QueryFilterBuilder

  @empty_config %Solage.QueryConfig{}

  test "nil filter" do
    filter = Solage.QueryFilterBuilder.build(nil, @empty_config)
    assert filter == %{}
  end

  test "empty string filter" do
    filter = Solage.QueryFilterBuilder.build("", @empty_config)
    assert filter == %{}
  end

  test "non map filter" do
    filter = Solage.QueryFilterBuilder.build("test123", @empty_config)
    assert filter == %{}
  end

  test "simple filter" do
    filter = Solage.QueryFilterBuilder.build(%{"organization_id" => "test"}, @empty_config)
    assert filter == %{"organization_id" => "test"}
  end

  test "allowed_filters" do
    config = %{@empty_config | options: [allowed_filters: ~w(organization_id)]}
    filter = Solage.QueryFilterBuilder.build(%{"organization_id" => "test", "user_id" => "123"}, config)
    assert filter == %{"organization_id" => "test"}
  end
end
