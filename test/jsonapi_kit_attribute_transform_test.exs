defmodule SolageAttributeTransformTest do
  use ExUnit.Case
  doctest Solage.AttributeTransform

  defmodule DefaultTest do
    use ExUnit.Case

    test "attributes" do
      params = %{
        "type" => "post",
        "attributes" => %{
          "name" => "Testy"
        }
      }

      assert %{"post" => %{"name" => "Testy"}} == Solage.AttributeTransform.decode(params)
    end

    test "relationship belongs_to" do
      params = %{
        "type" => "post",
        "relationships" => %{
          "user" => %{
            "data" => %{
              "id" => "1"
            }
          }
        }
      }

      assert %{"post" => %{"user_id" => "1"}} == Solage.AttributeTransform.decode(params)
    end

    test "relationship has_many" do
      params = %{
        "type" => "post",
        "relationships" => %{
          "user" => %{
            "data" => [%{
              "id" => "1"
            }]
          }
        }
      }

      assert %{"post" => %{"user_ids" => ["1"]}} == Solage.AttributeTransform.decode(params)
    end
  end
end
