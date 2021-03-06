defmodule U2FEx.Utils.Crypto do
  @moduledoc false

  alias U2FEx.{SignResponse, RegistrationResponse, Utils}

  @doc """
  Hashes the input text using sha256
  """
  @spec sha256(input :: String.t()) :: binary()
  def sha256(input) when is_binary(input) do
    :crypto.hash(:sha256, input)
  end

  @min_challenge_num_bytes 8

  @doc """
  Handles generating a challenge for the U2F device to verify against.
  """
  @spec generate_challenge(byte_len :: integer()) :: String.t()
  def generate_challenge(num_bytes \\ 32) when num_bytes > @min_challenge_num_bytes do
    num_bytes
    |> :crypto.strong_rand_bytes()
    |> Utils.b64_encode()
  end

  @doc """
  Verifies the devices response against the challenge
  """
  @spec verify_registration_response(RegistrationResponse.t(), client_data :: binary()) ::
          :ok | {:error, atom()}
  def verify_registration_response(
        %RegistrationResponse{
          key_handle: key_handle,
          public_key: public_key,
          signature: signature,
          attestation_cert: certificate
        },
        client_data
      ) do
    decoded_client_data = Utils.b64_decode(client_data)
    client_data_map = decoded_client_data |> Jason.decode!()

    constructed_string =
      <<0>> <>
        sha256(Map.get(client_data_map, "origin")) <>
        sha256(decoded_client_data) <> key_handle <> public_key

    certificate_public_key =
      certificate
      |> get_certificate_public_key()
      |> X509.PublicKey.unwrap()

    case :public_key.verify(
           constructed_string,
           :sha256,
           signature,
           certificate_public_key
         ) do
      true ->
        :ok

      false ->
        {:error, :signature_verification_failed}
    end
  end

  @spec verify_authentication_response(SignResponse.t(), public_key :: binary()) ::
          :ok | {:error, :signature_verification_failed}
  def verify_authentication_response(
        %SignResponse{
          signature: signature,
          app_id: app_id,
          user_presence: user_presence,
          counter: counter,
          client_data: client_data,
          key_handle: _key_handle,
          challenge: _challenge
        } = _sign_response,
        public_key
      )
      when is_binary(public_key) do
    constructed_string = sha256(app_id) <> user_presence <> counter <> sha256(client_data)

    case :crypto.verify(:ecdsa, :sha256, constructed_string, signature, [
           public_key,
           :prime256v1
         ]) do
      true ->
        :ok

      false ->
        {:error, :signature_verification_failed}
    end
  end

  ##############################
  # Internal Private Functions #
  ##############################

  @spec get_certificate_public_key(tuple()) :: tuple()
  defp get_certificate_public_key({:Certificate, tbs, _, _}) do
    tbs
    |> Tuple.to_list()
    |> Enum.at(7)
  end
end
