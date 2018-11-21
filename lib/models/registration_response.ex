defmodule U2FEx.RegistrationResponse do
  @moduledoc false

  @type t :: %__MODULE__{
          public_key: binary(),
          key_handle: binary(),
          attestation_cert: tuple(),
          signature: binary()
        }

  alias U2FEx.Utils.Crypto
  use Bitwise

  @public_key_len 65 * 8
  @key_handle_length_len 1 * 8

  @required_keys [:public_key, :key_handle, :attestation_cert, :signature]
  defstruct @required_keys

  @doc """
  """
  @spec new(
          public_key :: binary,
          key_handle :: binary(),
          attestation_cert :: tuple(),
          signature :: binary()
        ) :: {:ok, __MODULE__.t()}
  def new(public_key, key_handle, attestation_cert, signature)
      when is_binary(public_key) and is_binary(key_handle) and is_binary(signature) do
    {:ok,
     struct!(
       __MODULE__,
       public_key: public_key,
       key_handle: key_handle,
       attestation_cert: attestation_cert,
       signature: signature
     )}
  end

  @doc """
  Deserializes a binary RegistrationResponse so that we can verify the device.
  """
  @spec from_binary(registration_response :: binary()) :: {:ok, __MODULE__.t()}
  def from_binary(registration_response) when is_binary(registration_response) do
    <<5::8, public_key::size(@public_key_len), key_handle_length::size(@key_handle_length_len),
      rest::binary()>> = registration_response

    total_key_handle_len = key_handle_length * 8
    <<key_handle::size(total_key_handle_len), cert_and_sig::binary>> = rest

    {certificate, signature} = parse_cert_and_sig(cert_and_sig)

    new(
      <<public_key::size(@public_key_len)>>,
      <<key_handle::size(total_key_handle_len)>>,
      X509.from_der(certificate, :Certificate),
      signature
    )
  end

  @doc """
  Parses a Json response into a RegistrationResponse
  """
  @spec from_json(String.t()) :: {:ok, __MODULE__.t()} | {:error, atom()}
  def from_json(json_input) when is_binary(json_input) do
    case Jason.decode(json_input) do
      {:ok, decoded} ->
        decoded
        |> Map.get("registrationData")
        |> Crypto.b64_decode()
        |> from_binary()

      {:error, %Jason.DecodeError{}} ->
        {:error, :invalid_json}
    end
  end

  ##############################
  # Private Internal Functions #
  ##############################

  @spec certificate_length(binary) :: binary()
  defp certificate_length(<<_res::8, 0::1, len::7, _rest::binary>>) do
    len * 8
  end

  defp certificate_length(<<_res::8, 1::1, octet_len::7, rest::binary>>) do
    total_octet_len = octet_len * 8
    <<len::size(total_octet_len), _rest::binary>> = rest
    (2 + octet_len + len) * 8
  end

  @spec parse_cert_and_sig(cert_and_sig :: binary()) ::
          {certificate :: binary(), signature :: binary()}
  defp parse_cert_and_sig(cert_and_sig) when is_binary(cert_and_sig) do
    cert_len = certificate_length(cert_and_sig)
    <<certificate::size(cert_len), signature::binary>> = cert_and_sig
    {<<certificate::size(cert_len)>>, <<signature::binary>>}
  end
end
