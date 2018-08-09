defmodule U2FEx.RegistrationRequest do
  @moduledoc """
  Represents an outgoing registration request. The U2F device will take this and then be prompted to respond.
  """

  alias U2FEx.Utils.Crypto

  @challenge_len 32
  @app_id_len 32

  @required_keys [:challenge, :app_id]
  defstruct @required_keys

  @doc """
  Creates a new RegistrationRequest.
  """
  @spec new(challenge :: String.t(), app_id :: String.t()) :: %__MODULE__{}
  def new(challenge, app_id)
      when byte_size(challenge) == @challenge_len and byte_size(app_id) == @app_id_len do
    %__MODULE__{
      challenge: challenge,
      app_id: app_id
    }
  end

  @doc """
  Serializes a RegistrationRequest so that the u2f device can read it.
  """
  @spec serialize(%__MODULE__{}) :: String.t()
  def serialize(%__MODULE__{challenge: challenge, app_id: app_id}) do
    Crypto.sha256(challenge) <> Crypto.sha256(app_id)
  end
end
