defmodule U2FEx.RegistrationRequest do
  @moduledoc false

  alias U2FEx.RegisteredKey

  @type b64_string :: String.t()
  @type t :: %__MODULE__{
          challenge: binary(),
          app_id: binary(),
          version: String.t()
        }

  alias U2FEx.Utils
  alias U2FEx.Utils.Crypto

  @required_keys [:challenge, :app_id, :version]
  defstruct @required_keys

  @doc """
  Creates a new RegistrationRequest.
  """
  @spec new(challenge :: String.t(), app_id :: String.t(), version :: String.t()) ::
          __MODULE__.t()
  def new(challenge, app_id, version \\ "U2F_V2") do
    struct!(
      __MODULE__,
      challenge: challenge,
      app_id: app_id,
      version: version
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
  Serializes a RegistrationRequest to a map so that the calling application can use it.
  """
  @spec to_map(__MODULE__.t(), registered_keys :: [RegisteredKey.t()]) :: %{
          required(:registerRequests) => %{
            required(:version) => String.t(),
            required(:challenge) => String.t(),
            required(:appId) => String.t()
          },
          required(:registeredKeys) => %{
            required(:version) => String.t(),
            required(:keyHandle) => b64_string,
            required(:appId) => String.t(),
            optional(:transports) => [any()]
          }
        }
  def to_map(
        %__MODULE__{
          challenge: challenge,
          app_id: app_id,
          version: version
        },
        keys
      )
      when is_list(keys) do
    %{
      registerRequests: [
        version: version,
        challenge: Utils.b64_encode(challenge),
        appId: app_id
      ],
      registeredKeys: Enum.map(keys, &RegisteredKey.to_map/1)
    }
  end
end
