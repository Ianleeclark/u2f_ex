defmodule U2FExTest.RegistrationRequestTest do
  use ExUnit.Case

  alias U2FEx.RegistrationRequest
  alias U2FEx.Utils.Crypto

  @test_data1 %{
    challenge: "8OlECVObN8NF5pK/Y8HhHkW22aN2HQjVX16LmVADNm0",
    clientData:
      "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZmluaXNoRW5yb2xsbWVudCIsImNoYWxsZW5nZSI6IjhPbEVDVk9iTjhORjVwSy9ZOEhoSGtXMjJhTjJIUWpWWDE2TG1WQURObTAiLCJvcmlnaW4iOiJodHRwczovL2xvY2FsaG9zdCIsImNpZF9wdWJrZXkiOiJ1bnVzZWQifQ",
    registrationData:
      "BQQfndLTYhIV0CIoHlukIvACGdq0lvWDLbMNvg0Sv-k_KqfGmy8oXRK7rrxnqzpQhOQxw6c0QN_3sodsfUk2ZN4hQACMQgJUFsG_YwGQa5Xb7lCp8wd8uaHYvvYLQS70pACAj8wxqaDtAWb_kg3Iez2WjnABs-R-d7efVG10wqCIzbkwggE1MIHcoAMCAQICCwCegZzEADyR1c9SMAoGCCqGSM49BAMCMBUxEzARBgNVBAMTClUyRiBJc3N1ZXIwGhcLMDAwMTAxMDAwMFoXCzAwMDEwMTAwMDBaMBUxEzARBgNVBAMTClUyRiBEZXZpY2UwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAT4XOBfQC0IkRduPe2mQOz3bRhvk_K5L9-m2a5PJA9uLESpwcWbOnjs8NNA1gFCX4vh9-asujcbngMAJSBZPKr7oxcwFTATBgsrBgEEAYLlHAIBAQQEAwIFIDAKBggqhkjOPQQDAgNIADBFAiEAwaOmji8WpyFGJwV_YrtyjJ4D56G6YtBGUk5FbSwvP3MCIAtfeOURqhgSn28jbZITIn2StOZ-31PoFt-wXZ3IuQ_eMEQCIAFe6VSB64w1AcThyrNpNDHiMYRLdxHj13PG8DkALMKuAiBmwRgIECXKTWY_bNntjjZzR31xGHRkhA1LkcliiBeMjw"
  }

  @test_data2 %{
    challenge: "XRIM/BUav4OUUUltwIyZJQ7ev8WVOR2pcWq9lCYWZXU",
    clientData:
      "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZmluaXNoRW5yb2xsbWVudCIsImNoYWxsZW5nZSI6IlhSSU0vQlVhdjRPVVVVbHR3SXlaSlE3ZXY4V1ZPUjJwY1dxOWxDWVdaWFUiLCJvcmlnaW4iOiJodHRwczovL2xvY2FsaG9zdCIsImNpZF9wdWJrZXkiOiJ1bnVzZWQifQ",
    registrationData:
      "BQQ-orXOqRsKH9aUmgBSSjPVztuP9dz2piNcId7P49w6Y_0sjEHazfXTOfNrbQ3euI2igqZo9yWfyfm0Z-8flfVnQFL6OsMTaj7uLO_3yyhbFAO4VBWm8FLGRNKF89d9UFIILfJR2ClwsAKKg3z7RZBAtgG12V3rOPLX6cAHvqBWkkgwggE0MIHboAMCAQICCnLPjQzGub2dlvUwCgYIKoZIzj0EAwIwFTETMBEGA1UEAxMKVTJGIElzc3VlcjAaFwswMDAxMDEwMDAwWhcLMDAwMTAxMDAwMFowFTETMBEGA1UEAxMKVTJGIERldmljZTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABKvlg--ffLAV1IE_Hyuj7YODsQRF3tlEyv5qFJcLNfFO-d_Oa4dC5LgghZMibAT8fSzf5lOXLpblZUwyzWd4eQ-jFzAVMBMGCysGAQQBguUcAgEBBAQDAgUgMAoGCCqGSM49BAMCA0gAMEUCIQDBo6aOLxanIUYnBX9iu3KMngPnobpi0EZSTkVtLC8_cwIgC1945RGqGBKfbyNtkhMifZK05n7fU-gW37Bdnci5D94wRQIgRbAhf7N3N1gizOrJ5jHvv_EZw8xUQ6SpLgnWw6AF19YCIQDtZSHWQC9PQwEFAouofue40zmjzPBfdkzK1bOd1rch8Q"
  }

  @test_datasets [@test_data1, @test_data2]

  describe "Verifying proper functionality for registration request." do
    test "new/2" do
      challenge = Crypto.generate_challenge(32)
      app_id = "https://ianleeclark.com"
      request = RegistrationRequest.new(challenge, app_id)
      assert request.challenge == challenge
      assert request.app_id == app_id
    end

    test "to_binary/1" do
      challenge = Crypto.generate_challenge(32)
      app_id = "https://ianleeclark.com"
      request = RegistrationRequest.new(challenge, app_id)

      <<challenge_bytes::256, app_id_bytes::256>> = RegistrationRequest.to_binary(request)
      assert Crypto.sha256(challenge) == <<challenge_bytes::256>>
      assert Crypto.sha256(app_id) == <<app_id_bytes::256>>
    end

    test "to_json/1" do
      challenge = Crypto.generate_challenge(32)
      app_id = "https://ianleeclark.com"
      request = RegistrationRequest.new(challenge, app_id)

      json_request = RegistrationRequest.to_json(request)
      assert is_binary(json_request)

      decoded_request = Jason.decode!(json_request)
      assert Crypto.b64_decode(decoded_request["challenge"]) == challenge
      assert Crypto.b64_decode(decoded_request["appId"]) == app_id
    end
  end

  describe "Testing against live testing data" do
    test "Verify all test data can parse/verify properly" do
      @test_datasets
      |> Enum.map(fn test_data ->
        assert :ok ==
                 test_data
                 |> Jason.encode!()
                 |> RegistrationResponse.from_json()
                 |> Crypto.verify_registration_response(test_data.clientData)
      end)
    end
  end
end
