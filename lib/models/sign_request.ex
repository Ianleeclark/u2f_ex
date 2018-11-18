defmodule U2FEx.SignRequest do
  @moduledoc """
  Represents an outgoing registration request. The U2F device will take this and then be prompted to respond.
  """

  alias U2FEx.RegisteredKey

  @type t :: %__MODULE__{
          challenge: binary(),
          registered_keys: [RegisteredKey.t()]
        }

  @required_keys [:challenge, :registered_keys]
  defstruct @required_keys

  @doc """
  Creates a new SignRequest. Should not be publicly called, see: from_json/1
  """
  @spec new(challenge :: String.t(), registered_keys :: [RegisteredKey.t()]) :: __MODULE__.t()
  def new(challenge, registered_keys) do
    struct!(
      __MODULE__,
      challenge: challenge,
      registered_keys: registered_keys
    )
  end

  @spec from_json(json_blob :: String.t()) :: __MODULE__.t()
  def from_json(json_blob) when is_binary(json_blob) do
    decoded_json =
      json_blob
      |> Jason.decode!()

    struct!(
      __MODULE__,
      challenge: decoded_json.challenge,
      registered_keys: decoded_json.registeredKeys
    )
  end
end
