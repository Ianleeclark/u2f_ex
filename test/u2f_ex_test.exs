defmodule U2FExTest do
  use ExUnit.Case
  doctest U2FEx

  @registration_data %{
    challenge: "8OlECVObN8NF5pK/Y8HhHkW22aN2HQjVX16LmVADNm0",
    clientData:
      "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZmluaXNoRW5yb2xsbWVudCIsImNoYWxsZW5nZSI6IjhPbEVDVk9iTjhORjVwSy9ZOEhoSGtXMjJhTjJIUWpWWDE2TG1WQURObTAiLCJvcmlnaW4iOiJodHRwczovL2xvY2FsaG9zdCIsImNpZF9wdWJrZXkiOiJ1bnVzZWQifQ",
    registrationData:
      "BQQfndLTYhIV0CIoHlukIvACGdq0lvWDLbMNvg0Sv-k_KqfGmy8oXRK7rrxnqzpQhOQxw6c0QN_3sodsfUk2ZN4hQACMQgJUFsG_YwGQa5Xb7lCp8wd8uaHYvvYLQS70pACAj8wxqaDtAWb_kg3Iez2WjnABs-R-d7efVG10wqCIzbkwggE1MIHcoAMCAQICCwCegZzEADyR1c9SMAoGCCqGSM49BAMCMBUxEzARBgNVBAMTClUyRiBJc3N1ZXIwGhcLMDAwMTAxMDAwMFoXCzAwMDEwMTAwMDBaMBUxEzARBgNVBAMTClUyRiBEZXZpY2UwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAT4XOBfQC0IkRduPe2mQOz3bRhvk_K5L9-m2a5PJA9uLESpwcWbOnjs8NNA1gFCX4vh9-asujcbngMAJSBZPKr7oxcwFTATBgsrBgEEAYLlHAIBAQQEAwIFIDAKBggqhkjOPQQDAgNIADBFAiEAwaOmji8WpyFGJwV_YrtyjJ4D56G6YtBGUk5FbSwvP3MCIAtfeOURqhgSn28jbZITIn2StOZ-31PoFt-wXZ3IuQ_eMEQCIAFe6VSB64w1AcThyrNpNDHiMYRLdxHj13PG8DkALMKuAiBmwRgIECXKTWY_bNntjjZzR31xGHRkhA1LkcliiBeMjw"
  }

  @authentication_data %{
    clientData:
      "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIiwiY2hhbGxlbmdlIjoiMzJXZDNIZnZHam1MbUtEWm0xMUlaem1xWVZnTm9jdFl1dnNXY0x4Q05EayIsIm9yaWdpbiI6Imh0dHBzOi8vbG9jYWxob3N0IiwiY2lkX3B1YmtleSI6InVudXNlZCJ9",
    keyHandle:
      "Uvo6wxNqPu4s7_fLKFsUA7hUFabwUsZE0oXz131QUggt8lHYKXCwAoqDfPtFkEC2AbXZXes48tfpwAe-oFaSSA",
    signatureData:
      "AQAAAAAwRgIhAJ9tmKoh1Ggx3QdHy8xkbEBKcl9-AxUklGZdmm8fJ__0AiEA-BAIKvUqd12F9tL2qSlmsrUq4qdcyF_7qu0iaKY47X4"
  }

  describe "Registration process" do
    test "Starting and finishing registration" do
      username = "user001"

      results =
        username
        |> U2FEx.start_registration()
        |> Map.put(:challenge, @registration_data.challenge)

      assert :ok ==
               GenServer.call(
                 U2FEx.Utils.ChallengeStore,
                 {:store_challenge, username, results.challenge}
               )

      register_result = U2FEx.finish_registration(username, Jason.encode!(@registration_data))

      assert register_result |> elem(0) == :ok
    end

    test "Lookup challenges can fail" do
      register_result =
        U2FEx.finish_registration("Nonexistent", Jason.encode!(@registration_data))

      assert {:error, :no_challenge_found} == register_result
    end
  end

  describe "Authentication process" do
    test "Starting and finishing authentication" do
      username = "asdf"

      start_results = U2FEx.start_authentication(username)
      assert is_map(start_results)
      assert is_binary(Map.get(start_results, :challenge))

      assert :ok == U2FEx.finish_authentication(username, Jason.encode!(@authentication_data))
    end
  end
end
