defmodule JsonapiKitDataTransformTest do
  defmodule DecodeTest do
    use ExUnit.Case

    test "any" do
      assert 1 == JsonapiKit.DataTransform.decode(1)
      assert :hello == JsonapiKit.DataTransform.decode(:hello)
    end

    test "list" do
      assert [1, 2, 3] == JsonapiKit.DataTransform.decode([1,2,3])
      assert ["hello-test"] == JsonapiKit.DataTransform.decode(["hello-test"])
    end

    test "map" do
      assert %{"hello_test" => "ok-go"} == JsonapiKit.DataTransform.decode(%{"hello-test" => "ok-go"})
    end
  end

  defmodule EncodeTest do
    use ExUnit.Case

    test "any" do
      assert 1 == JsonapiKit.DataTransform.encode(1)
      assert :hello == JsonapiKit.DataTransform.encode(:hello)
    end

    test "list" do
      assert [1, 2, 3] == JsonapiKit.DataTransform.encode([1,2,3])
      assert ["hello-test"] == JsonapiKit.DataTransform.encode(["hello-test"])
    end

    test "map" do
      assert %{"hello-test" => "ok-go"} == JsonapiKit.DataTransform.encode(%{"hello_test" => "ok-go"})
    end
  end
end
