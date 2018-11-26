defmodule U2FEx.SignRequest do
  @moduledoc false

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
  @spec new(challenge :: String.t(), registered_keys :: [RegisteredKey.t()]) ::
          {:ok, __MODULE__.t()}
  def new(challenge, registered_keys) do
    {:ok,
     struct!(
       __MODULE__,
       challenge: challenge,
       registered_keys: registered_keys
     )}
  end

  @spec from_json(json_blob :: String.t()) :: {:ok, __MODULE__.t()}
  def from_json(json_blob) when is_binary(json_blob) do
    decoded_json =
      json_blob
      |> Jason.decode!()

    new(decoded_json.challenge, decoded_json.registered_keys)
  end

  @spec to_map(__MODULE__.t()) :: %{
          required(:challenge) => String.t(),
          required(:registered_keys) => [map()]
        }
  def to_map(%__MODULE__{challenge: challenge, registered_keys: registered_keys}) do
    %{
      challenge: challenge,
      registeredKeys: Enum.map(registered_keys, &RegisteredKey.to_map/1)
    }
  end
end
