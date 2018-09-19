defmodule U2FExTest.RegistrationRequestTest do
  use ExUnit.Case

  alias U2FEx.RegistrationRequest
  alias U2FEx.Utils.Crypto

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
end
