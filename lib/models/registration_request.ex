defmodule U2FEx.RegistrationRequest do
  @moduledoc false

  @type t :: %__MODULE__{
          challenge: binary(),
          app_id: binary()
        }

  alias U2FEx.Utils.Crypto

  @required_keys [:challenge, :app_id]
  defstruct @required_keys

  @doc """
  Creates a new RegistrationRequest.
  """
  @spec new(challenge :: String.t(), app_id :: String.t()) :: __MODULE__.t()
  def new(challenge, app_id) do
    struct!(
      __MODULE__,
      challenge: challenge,
      app_id: app_id
    )
  end

  @doc """
  Serializes a RegistrationRequest to binary so that the u2f device can read it.
  """
  @spec to_binary(__MODULE__.t()) :: String.t()
  def to_binary(%__MODULE__{challenge: challenge, app_id: app_id}) do
    Crypto.sha256(challenge) <> Crypto.sha256(app_id)
  end

  @doc """
  Serializes a RegistrationRequest to Json so that the javascript API can handle it.
  """
  @spec to_json(__MODULE__.t()) :: String.t()
  def to_json(%__MODULE__{challenge: challenge, app_id: app_id}) do
    %{
      version: "U2F_V2",
      challenge: Crypto.b64_encode(challenge),
      appId: Crypto.b64_encode(app_id)
    }
    |> Jason.encode!()
  end
end
