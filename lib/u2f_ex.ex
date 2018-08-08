defmodule U2fEx do
  @moduledoc """
  Handles registration and authentication of incoming U2F requests.
  """

  @doc """
  Begins a registration request by creating a challenge.
  """
  @spec start_registration(username :: String.t()) :: String.t()
  def start_registration(username) when is_binary(username) do
  end

  @doc """
  Verifies registration is complete by checking the challenge.
  """
  @spec finish_registration(username :: String.t(), device_response :: binary) :: boolean()
  def finish_registration(username, device_response) when is_binary(username) and is_binary(device_response) do
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
