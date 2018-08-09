defmodule U2FEx do
  @moduledoc """
  Handles registration and authentication of incoming U2F requests.
  """
  # Determine if this is how we want to do this.
  # @app_id Application.get_env(:u2fex, :application_name)
  @app_id "https://ianleeclark.com"

  alias U2FEx.{RegistrationRequest, RegistrationResponse}
  alias U2FEx.Utils.{Crypto, ChallengeStore}

  @doc """
  Begins a registration request by creating a challenge.
  """
  @spec start_registration(username :: String.t()) ::
          {:ok, binary()} | {:error, :failed_to_store_challenge}
  def start_registration(username) when is_binary(username) do
    challenge = Crypto.generate_challenge(32)

    case GenServer.call(ChallengeStore, {:store_challenge, username, challenge}) do
      :ok ->
        challenge
        |> RegistrationRequest.new(@app_id)
        |> RegistrationRequest.serialize()

      {:error, _reason} ->
        {:error, :failed_to_store_challenge}
    end
  end

  @doc """
  Verifies registration is complete by checking the challenge.
  """
  @spec finish_registration(username :: String.t(), device_response :: binary) :: boolean()
  def finish_registration(username, device_response)
      when is_binary(username) and is_binary(device_response) do
    with {:ok, challenge} <- GenServer.call(ChallengeStore, {:retrieve_challenge, username}),
         registration_response = RegistrationResponse.deserialize(device_response),
         :ok <- Crypto.verify_response(registration_response.signature, challenge),
         :ok <- GenServer.call(ChallengeStore, {:remove_challenge, username}) do
      :ok
    else
      error ->
        error
    end
  end

  @doc """
  Starts authentication against a known U2F token.
  """
  @spec start_authentication() :: %{}
  def start_authentication do
  end

  @doc """
  Finishes authentication for a known U2F token.
  """
  @spec finish_authentication() :: %{}
  def finish_authentication do
  end
end
