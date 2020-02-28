defmodule U2FEx do
  @moduledoc """
  Handles registration and authentication of incoming U2F requests.
  """

  import Application, only: [get_env: 2]

  alias U2FEx.Utils
  alias U2FEx.Utils.{Crypto, ChallengeStore}

  alias U2FEx.{
    KeyMetadata,
    RegisteredKey,
    RegistrationRequest,
    RegistrationResponse,
    SignRequest,
    SignResponse
  }

  @challenge_len 32

  @doc """
  Begins a registration request by creating a challenge. You should send the resulting data to the
  u2f device.
  """
  @spec start_registration(user_id :: String.t()) ::
          {:ok,
           registration_request :: %{
             required(:version) => String.t(),
             required(:challenge) => String.t(),
             required(:appId) => String.t()
           }}
          | {:error, :failed_to_store_challenge}
  def start_registration(user_id) when is_binary(user_id) do
    challenge = Crypto.generate_challenge(@challenge_len)
    pki_storage = get_env(:u2f_ex, :pki_storage)

    with :ok <- GenServer.call(ChallengeStore, {:store_challenge, user_id, challenge}),
         {:ok, registered_keys} <- pki_storage.list_key_handles_for_user(user_id) do
      app_id = get_env(:u2f_ex, :app_id)

      registration_request =
        challenge
        |> RegistrationRequest.new(app_id)
        |> RegistrationRequest.to_map(registered_keys)

      updated_keys =
        registration_request.registeredKeys
        |> Enum.map(fn %{keyHandle: kh} = key -> %{key | keyHandle: Utils.b64_encode(kh)} end)

      {:ok, Map.put(registration_request, :registeredKeys, updated_keys)}
    else
      {:error, _reason} ->
        {:error, :failed_to_store_challenge}
    end
  end

  @doc """
  Finishes registration. You'll need to persist the data in KeyMetadata struct to whatever database
  your heart desires.
  """
  @spec finish_registration(user_id :: String.t(), device_response :: binary) ::
          {:ok, KeyMetadata.t()}
  def finish_registration(user_id, device_response) when is_map(device_response) do
    finish_registration(user_id, Jason.encode!(device_response))
  end

  def finish_registration(user_id, device_response)
      when is_binary(user_id) and is_binary(device_response) do
    with {:ok, challenge} <- GenServer.call(ChallengeStore, {:retrieve_challenge, user_id}),
         {:ok, %RegistrationResponse{} = response} <-
           RegistrationResponse.from_json(device_response),
         {:ok, %{"clientData" => client_data}} <- Jason.decode(device_response),
         :ok <- Crypto.verify_registration_response(response, client_data),
         :ok <- GenServer.call(ChallengeStore, {:remove_challenge, challenge}) do
      RegistrationResponse.to_key_metadata(response)
    else
      error ->
        error
    end
  end

  @doc """
  Starts authentication by using the previously stored key metadata to force the requesting
  user prove their identity. Send the resulting map to the u2f device.
  """
  @spec start_authentication(user_id :: String.t()) ::
          {:ok,
           auth_request :: %{
             required(:challenge) => String.t(),
             required(:registered_keys) => [map()]
           }}
          | {:error, atom()}
  def start_authentication(user_id) when is_binary(user_id) do
    challenge = Crypto.generate_challenge(@challenge_len)
    pki_storage = get_env(:u2f_ex, :pki_storage)

    with {:ok, user_keys} when is_list(user_keys) <-
           pki_storage.list_key_handles_for_user(user_id) do
      app_id = get_env(:u2f_ex, :app_id)
      registered_keys =
        user_keys
        |> Enum.map(fn %{version: version, key_handle: handle} = key ->
          version
          |> RegisteredKey.new(
            handle,
            Map.get(key, :app_id, app_id),
            Map.get(key, :transports, nil)
          )
        end)

      auth_request =
        challenge
        |> SignRequest.new(registered_keys)
        |> elem(1)
        |> SignRequest.to_map()

      {:ok, auth_request}
    end
  end

  @doc """
  Finishes authentication. Once this has passed, the user is deemed to have sufficiently
  proved their identity.
  """
  @spec finish_authentication(user_id :: String.t(), device_response :: binary()) ::
          :ok
          | {:error, :signature_verification_failed}
          | {:error, :public_key_not_found}
          | {:error, atom()}
  def finish_authentication(user_id, device_response)
      when is_binary(user_id) do
    pki_storage = get_env(:u2f_ex, :pki_storage)

    with {:ok, %SignResponse{} = sign_response} <- SignResponse.from_json(device_response),
         {:ok, public_key} <-
           pki_storage.get_public_key_for_user(
             user_id,
             sign_response.key_handle |> Utils.b64_encode()
           ),
         :ok <- Crypto.verify_authentication_response(sign_response, Utils.b64_decode(public_key)) do
      :ok
    else
      error -> error
    end
  end
end
