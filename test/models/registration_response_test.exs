defmodule U2FEx.RegistrationResponseTest do
  use ExUnit.Case

  alias U2FEx.RegistrationResponse

  @testdata1 %{
    challenge: "8OlECVObN8NF5pK/Y8HhHkW22aN2HQjVX16LmVADNm0",
    clientData:
      "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZmluaXNoRW5yb2xsbWVudCIsImNoYWxsZW5nZSI6IjhPbEVDVk9iTjhORjVwSy9ZOEhoSGtXMjJhTjJIUWpWWDE2TG1WQURObTAiLCJvcmlnaW4iOiJodHRwczovL2xvY2FsaG9zdCIsImNpZF9wdWJrZXkiOiJ1bnVzZWQifQ",
    registrationData:
      "BQQfndLTYhIV0CIoHlukIvACGdq0lvWDLbMNvg0Sv-k_KqfGmy8oXRK7rrxnqzpQhOQxw6c0QN_3sodsfUk2ZN4hQACMQgJUFsG_YwGQa5Xb7lCp8wd8uaHYvvYLQS70pACAj8wxqaDtAWb_kg3Iez2WjnABs-R-d7efVG10wqCIzbkwggE1MIHcoAMCAQICCwCegZzEADyR1c9SMAoGCCqGSM49BAMCMBUxEzARBgNVBAMTClUyRiBJc3N1ZXIwGhcLMDAwMTAxMDAwMFoXCzAwMDEwMTAwMDBaMBUxEzARBgNVBAMTClUyRiBEZXZpY2UwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAT4XOBfQC0IkRduPe2mQOz3bRhvk_K5L9-m2a5PJA9uLESpwcWbOnjs8NNA1gFCX4vh9-asujcbngMAJSBZPKr7oxcwFTATBgsrBgEEAYLlHAIBAQQEAwIFIDAKBggqhkjOPQQDAgNIADBFAiEAwaOmji8WpyFGJwV_YrtyjJ4D56G6YtBGUk5FbSwvP3MCIAtfeOURqhgSn28jbZITIn2StOZ-31PoFt-wXZ3IuQ_eMEQCIAFe6VSB64w1AcThyrNpNDHiMYRLdxHj13PG8DkALMKuAiBmwRgIECXKTWY_bNntjjZzR31xGHRkhA1LkcliiBeMjw"
  }

  test "ensure from_json/1 with maps" do
    input_data = @testdata1

    input_data_atomized =
      input_data
      |> Enum.into(%{}, fn {key, val} when is_atom(key) -> {Atom.to_string(key), val} end)

    map_data = input_data_atomized

    assert RegistrationResponse.from_json(map_data) |> elem(0) == :ok
  end

  test "ensure from_json/1 with strings" do
    input_data = @testdata1
    string_data = Jason.encode!(input_data)

    assert RegistrationResponse.from_json(string_data) |> elem(0) == :ok
  end
end
