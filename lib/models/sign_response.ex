defmodule U2FEx.SignResponse do
  @moduledoc false

  @type t :: %__MODULE__{
          key_handle: binary(),
          challenge: String.t(),
          app_id: String.t(),
          user_presence: binary(),
          counter: number(),
          signature: binary()
        }

  alias U2FEx.Utils.Crypto

  @challenge_len 32 * 8
  @key_handle_length_len 1 * 8
  @app_id_len 32 * 8
  @counter_len 4 * 8

  # TODO(ian): Replace with config value
  @app_id "https://localhost"

  @required_keys [:key_handle, :challenge, :app_id, :user_presence, :counter, :signature]
  defstruct @required_keys

  @doc """
  Creates a new SignResponse. Should not be publicly called, see: from_json/1 and from_binary/2
  """
  @spec new(
          key_handle :: binary(),
          challenge :: String.t(),
          user_presence :: binary(),
          counter :: number(),
          signature :: binary()
        ) :: {:ok, __MODULE__.t()}
  def new(key_handle, challenge, user_presence, counter, signature)
      when is_binary(key_handle) and is_binary(user_presence) and is_binary(counter) and
             is_binary(signature) and is_binary(challenge) do
    {:ok,
     struct!(
       __MODULE__,
       key_handle: key_handle,
       challenge: challenge,
       app_id: @app_id,
       user_presence: user_presence,
       counter: counter,
       signature: signature
     )}
  end

  @spec from_binary(client_data :: binary(), signature :: binary()) :: {:ok, __MODULE__.t()}
  def from_binary(client_data, signature_data)
      when is_binary(client_data) and is_binary(signature_data) do
    # TODO(ian): Account for control byte, this should probably be stored
    <<_control::8, challenge::size(@challenge_len), _app_id::size(@app_id_len),
      _key_handle::size(@key_handle_length_len), key_handle::binary>> = client_data

    <<user_presence::8, counter::size(@counter_len), signature::binary>> = signature_data

    new(key_handle, challenge, user_presence, counter, signature)
  end

  @spec from_json(device_response :: String.t()) :: {:ok, __MODULE__.t()}
  def from_json(device_response) do
    decoded_json =
      device_response
      |> Jason.decode!()

    signature_data = decoded_json |> Map.get("signatureData") |> Crypto.b64_decode()
    client_data = decoded_json |> Map.get("clientData") |> Crypto.b64_decode()

    from_binary(client_data, signature_data)
  end
end
