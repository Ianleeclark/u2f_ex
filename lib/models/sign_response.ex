defmodule U2FEx.SignResponse do
  @moduledoc false

  @type t :: %__MODULE__{
          key_handle: binary(),
          challenge: String.t(),
          app_id: String.t(),
          user_presence: binary(),
          counter: binary(),
          signature: binary(),
          client_data: String.t()
        }

  alias U2FEx.Errors
  alias U2FEx.Utils

  @counter_len 4 * 8
  @app_id Application.get_env(:u2f_ex, :app_id)

  @required_keys [
    :key_handle,
    :challenge,
    :app_id,
    :user_presence,
    :counter,
    :signature,
    :client_data
  ]
  defstruct @required_keys

  @doc """
  Creates a new SignResponse. Should not be publicly called, see: from_json/1 and from_binary/2
  """
  @spec new(
          key_handle :: binary(),
          challenge :: String.t(),
          user_presence :: binary(),
          counter :: binary(),
          signature :: binary(),
          client_data :: String.t()
        ) :: {:ok, %__MODULE__{}}
  def new(key_handle, challenge, user_presence, counter, signature, client_data)
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
       signature: signature,
       client_data: client_data
     )}
  end

  @spec from_binary(key_handle :: binary(), client_data :: binary(), signature :: binary()) ::
          {:ok, __MODULE__.t()}
  def from_binary(key_handle, client_data, signature_data)
      when is_binary(client_data) and is_binary(signature_data) do
    challenge = client_data |> Jason.decode!() |> Map.get("challenge")

    <<user_presence::8, counter::size(@counter_len), signature::binary>> = signature_data

    new(
      key_handle,
      <<challenge::binary>>,
      <<user_presence::8>>,
      <<counter::size(@counter_len)>>,
      <<signature::binary>>,
      client_data
    )
  end

  @spec from_json(device_response :: String.t() | map) :: {:ok, __MODULE__.t()}
  def from_json(
        %{
          "keyHandle" => _key_handle,
          "clientData" => _client_data,
          "signatureData" => _signature_data
        } = x
      ) do
    do_from_json(x)
  end

  def from_json(%{"errorCode" => _error} = response) do
    do_from_json(response)
  end

  def from_json(device_response) do
    decoded_json =
      device_response
      |> Jason.decode!()

    case do_from_json(decoded_json) do
      {:error, _error} = err ->
        err

      _ ->
        do_from_json(decoded_json)
    end
  end

  @spec do_from_json(map()) ::
          any()
          | {:error,
             :u2f_other_error
             | :u2f_bad_request
             | :u2f_configuration_unsupported
             | :u2f_device_ineligible
             | :u2f_timeout}
  defp do_from_json(%{
         "signatureData" => s,
         "clientData" => c,
         "keyHandle" => k
       }) do
    signature_data = Utils.b64_decode(s)
    client_data = Utils.b64_decode(c)
    key_handle = Utils.b64_decode(k)
    from_binary(key_handle, client_data, signature_data)
  end

  defp do_from_json(%{"errorCode" => error}), do: Errors.get_retval_from_error(error)

end
