defmodule U2FExTest.SignResponseTest do
  use ExUnit.Case

  alias U2FEx.SignResponse
  alias U2FEx.Utils.Crypto

  @testdata1 %{
    clientData:
      "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIiwiY2hhbGxlbmdlIjoiMzJXZDNIZnZHam1MbUtEWm0xMUlaem1xWVZnTm9jdFl1dnNXY0x4Q05EayIsIm9yaWdpbiI6Imh0dHBzOi8vbG9jYWxob3N0IiwiY2lkX3B1YmtleSI6InVudXNlZCJ9",
    keyHandle:
      "Uvo6wxNqPu4s7_fLKFsUA7hUFabwUsZE0oXz131QUggt8lHYKXCwAoqDfPtFkEC2AbXZXes48tfpwAe-oFaSSA",
    signatureData:
      "AQAAAAAwRgIhAJ9tmKoh1Ggx3QdHy8xkbEBKcl9-AxUklGZdmm8fJ__0AiEA-BAIKvUqd12F9tL2qSlmsrUq4qdcyF_7qu0iaKY47X4"
  }

  @testdata2 %{
    clientData:
      "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIiwiY2hhbGxlbmdlIjoiaV9qQVVwcExYRzlxXzJJNFNVQWNHQlVXQkh2YXgxZm96VFVaSndnSENQNCIsIm9yaWdpbiI6Imh0dHBzOi8vbG9jYWxob3N0IiwiY2lkX3B1YmtleSI6InVudXNlZCJ9",
    keyHandle:
      "Uvo6wxNqPu4s7_fLKFsUA7hUFabwUsZE0oXz131QUggt8lHYKXCwAoqDfPtFkEC2AbXZXes48tfpwAe-oFaSSA",
    signatureData:
      "AQAAAAEwRAIgaToqQ_byEkxl1z43bSjOGuz8hp06fEKELRv58d0b1EECIEf47E3lk0XUI58YSxls-rjDQUqyTGAHr3C9JQIXf9vv"
  }

  @testdata3 %{
    clientData:
      "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIiwiY2hhbGxlbmdlIjoiSXlVbmM1QmlhQjA3NGwxNHBPWkNqS2VWVmgwT2VaTzhGNEdYcDhBQ3dUYyIsIm9yaWdpbiI6Imh0dHBzOi8vbG9jYWxob3N0IiwiY2lkX3B1YmtleSI6InVudXNlZCJ9",
    keyHandle:
      "Uvo6wxNqPu4s7_fLKFsUA7hUFabwUsZE0oXz131QUggt8lHYKXCwAoqDfPtFkEC2AbXZXes48tfpwAe-oFaSSA",
    signatureData:
      "AQAAAAIwRgIhANkFHJozsQhZ3L9cl8B1Qj9nBcU1pOOWxFm2-NnQmUOrAiEA0dIxGff4nI0Ka7jodzuU6pFhp7uxY3q44zD4qUx9xp8"
  }

  @test_data [@testdata1, @testdata2, @testdata3]

  @public_key "BD6itc6pGwof1pSaAFJKM9XO24_13PamI1wh3s_j3Dpj_SyMQdrN9dM582ttDd64jaKCpmj3JZ_J-bRn7x-V9Wc"
              |> Base.url_decode64!(padding: false)

  describe "Verify signing responses" do
    test "all test data" do
      @test_data
      |> Enum.map(fn test_data ->
        {:ok, sign_response} =
          test_data
          |> Jason.encode!()
          |> SignResponse.from_json()

        assert :ok == Crypto.verify_authentication_response(sign_response, @public_key)
      end)
    end
  end
end
