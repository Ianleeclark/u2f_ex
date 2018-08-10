defmodule U2FEx.RegistrationResponse do
  @moduledoc """
  Represents an incoming registration response
  """

  alias U2FEx.Utils.Crypto

  @reserved_byte_len 8
  @public_key_len 520
  @key_handle_length_len 8

  @required_keys [:public_key, :key_handle, :attestation_cert, :signature]
  defstruct @required_keys

  @doc """
  Deserializes a RegistrationResponse so that we can verify the device.
  """
  @spec deserialize(registration_response :: binary()) :: %__MODULE__{}
  def deserialize(registration_response) when is_binary(registration_response) do
    <<_reserved_byte::size(@reserved_byte_len), public_key::size(@public_key_len),
      key_handle_length::size(@key_handle_length_len), rest::binary>> = registration_response

    <<key_handle::size(key_handle_length), cert_and_sig::binary>> = rest

    {certificate, signature} = parse_cert_and_sig(cert_and_sig)

    %__MODULE__{
      public_key: public_key,
      key_handle: key_handle,
      attestation_cert: certificate,
      signature: signature
    }
  end

  @doc """
  Parses a Json response into a RegistrationResponse
  """
  @spec from_json(String.t()) :: {:ok, %__MODULE__{}} | {:error, atom()}
  def from_json(json_input) when is_binary(json_input) do
    case Jason.decode(json_input) do
      {:ok, decoded} ->
        decoded
        |> Map.get("registrationData")
        |> Crypto.b64_decode()
        |> deserialize()

      {:error, %Jason.DecodeError{}} ->
        {:error, :invalid_json}
    end
  end

  @spec parse_cert_and_sig(cert_and_sig :: binary()) ::
          {certificate :: binary(), signature :: binary()}
  defp parse_cert_and_sig(cert_and_sig) when is_binary(cert_and_sig) do
    <<_::16, cert_len::16, _::binary()>> = cert_and_sig
    total_cert_len = cert_len + 4
    <<_::16, certificate::size(total_cert_len), signature::binary>> = cert_and_sig
    {certificate, signature}
  end
end
