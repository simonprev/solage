defmodule JsonapiKit.SerializerTest do
  use ExUnit.Case

  defmodule IdView do
    def render(data, _config, _conn), do: data[:id]
    def relation_view(_), do: __MODULE__
  end

  test "data" do
    config = %JsonapiKit.QueryConfig{}
    data = JsonapiKit.Serializer.data(IdView, %{id: "post"}, config)

    assert data == ["post"]
  end

  test "simple included" do
    config = %JsonapiKit.QueryConfig{include: [:user]}
    data = JsonapiKit.Serializer.included(IdView, %{id: "test", user: %{id: "my-user"}}, config)

    assert data == ["my-user"]
  end

  test "simple array included" do
    config = %JsonapiKit.QueryConfig{include: [:users]}
    data = JsonapiKit.Serializer.included(IdView, %{id: "test", users: [%{id: "my-user"}, %{id: "user-two"}]}, config)

    assert data == ["my-user", "user-two"]
  end

  test "duplicated simple included" do
    config = %JsonapiKit.QueryConfig{include: [:user]}
    data = [%{id: "test", user: %{id: "my-user"}}, %{id: "test2", user: %{id: "my-user"}}]
    included = JsonapiKit.Serializer.included(IdView, data, config)

    assert included == ["my-user"]
  end

  test "duplicated array included" do
    config = %JsonapiKit.QueryConfig{include: [:users]}
    data = [%{id: "test", users: [%{id: "my-user"}, %{id: "user3"}]}, %{id: "test2", users: [%{id: "user2"}, %{id: "my-user"}]}]
    included = JsonapiKit.Serializer.included(IdView, data, config)

    assert included == ["my-user", "user2", "user3"]
  end

  test "multiple include" do
    config = %JsonapiKit.QueryConfig{include: [:user, :organization]}
    data = [%{id: "test", user: %{id: "my-user"}, organization: %{id: "my-organization"}}]
    included = JsonapiKit.Serializer.included(IdView, data, config)

    assert included == ["my-organization", "my-user"]
  end

  test "nested include" do
    config = %JsonapiKit.QueryConfig{include: [user: :organization]}
    data = [%{id: "test", user: %{id: "my-user", organization: %{id: "my-organization"}}}]
    included = JsonapiKit.Serializer.included(IdView, data, config)

    assert included == ["my-organization"]
  end
end
