defmodule U2FEx do
  @moduledoc """
  Handles registration and authentication of incoming U2F requests.
  """
  @app_id Application.get_env(:u2f_ex, :app_id)
  @pki_storage Application.get_env(:u2f_ex, :pki_storage)

  alias U2FEx.Utils.{Crypto, ChallengeStore}

  alias U2FEx.{
    RegistrationRequest,
    RegistrationResponse,
    SignRequest,
    SignResponse,
    RegisteredKey
  }

  @challenge_len 32
  @pki_storage Application.get_env(:u2f_ex, :pki_storage)

  @doc """
  Begins a registration request by creating a challenge.
  """
  @spec start_registration(username :: String.t()) ::
          {:ok, binary()} | {:error, :failed_to_store_challenge}
  def start_registration(username) when is_binary(username) do
    challenge = Crypto.generate_challenge(@challenge_len)

    case GenServer.call(ChallengeStore, {:store_challenge, username, challenge}) do
      :ok ->
        challenge
        |> RegistrationRequest.new(@app_id)
        |> RegistrationRequest.to_json()

      {:error, _reason} ->
        {:error, :failed_to_store_challenge}
    end
  end

  @doc """
  Verifies registration is complete by checking the challenge.
  """
  @spec finish_registration(challenge :: String.t(), device_response :: binary) :: boolean()
  def finish_registration(challenge, device_response)
      when is_binary(challenge) and is_binary(device_response) do
    with {:ok, challenge} <- GenServer.call(ChallengeStore, {:retrieve_challenge, challenge}),
         {:ok, %RegistrationResponse{signature: signature}} =
           RegistrationResponse.from_json(device_response),
         :ok <- Crypto.verify_registration_response(signature, challenge),
         :ok <- GenServer.call(ChallengeStore, {:remove_challenge, challenge}) do
      # TODO(ian): return the other useful information for a `registered_key`
      # TODO(ian): Instruct user to store that information
      :ok
    else
      error ->
        error
    end
  end

  @doc """
  Starts authentication against a known U2F token.
  """
  @spec start_authentication(user_id :: any()) :: %{}
  def start_authentication(user_id) do
    challenge = Crypto.generate_challenge(@challenge_len)

    with {:ok, user_keys} when is_list(user_keys) <-
           @pki_storage.list_key_handles_for_user(user_id) do
      registered_keys =
        user_keys
        |> Enum.map(fn %{version: version, key_handle: handle} = key ->
          RegisteredKey.new(
            version,
            handle,
            Map.get(key, :app_id, @app_id),
            Map.get(key, :transports, nil)
          )
        end)

      SignRequest.new(challenge, registered_keys)
    end
  end

  @doc """
  Finishes authentication for a known U2F token.
  """
  @spec finish_authentication(user_id :: any(), device_response :: binary()) :: %{}
  def finish_authentication(user_id, device_response) do
    with {:ok, %SignResponse{} = sign_response} <- SignResponse.from_json(device_response),
         {:ok, %{public_key: public_key}} <-
           @pki_storage.get_public_key_for_user(user_id, sign_response.key_handle),
         :ok <- Crypto.verify_authentication_response(sign_response, public_key) do
    end
  end
end
