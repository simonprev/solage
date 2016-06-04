defmodule SolageDataTransformTest do
  defmodule DecodeTest do
    use ExUnit.Case

    test "any" do
      assert 1 == Solage.DataTransform.decode(1)
      assert :hello == Solage.DataTransform.decode(:hello)
    end

    test "list" do
      assert [1, 2, 3] == Solage.DataTransform.decode([1,2,3])
      assert ["hello-test"] == Solage.DataTransform.decode(["hello-test"])
    end

    test "map" do
      assert %{"hello_test" => "ok-go"} == Solage.DataTransform.decode(%{"hello-test" => "ok-go"})
    end
  end

  defmodule EncodeTest do
    use ExUnit.Case

    test "any" do
      assert 1 == Solage.DataTransform.encode(1)
      assert :hello == Solage.DataTransform.encode(:hello)
    end

    test "list" do
      assert [1, 2, 3] == Solage.DataTransform.encode([1,2,3])
      assert ["hello-test"] == Solage.DataTransform.encode(["hello-test"])
    end

    test "map" do
      assert %{"hello-test" => "ok-go"} == Solage.DataTransform.encode(%{"hello_test" => "ok-go"})
    end
  end
end
