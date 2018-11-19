defmodule U2FEx.RegisteredKey do
  @moduledoc false
  @type t :: %__MODULE__{
          version: String.t(),
          keyHandle: String.t(),
          appId: String.t(),
          transports: [map()]
        }

  @required_keys [:version, :keyHandle, :appId, :transports]
  defstruct @required_keys

  @spec new(
          version :: String.t(),
          key_handle :: String.t(),
          appId :: String.t(),
          transports :: [map()]
        ) :: __MODULE__.t()
  def new(version, key_handle, app_id, transports \\ []) do
    struct!(
      __MODULE__,
      version: version,
      keyHandle: key_handle,
      appId: app_id,
      transports: transports
    )
  end
end
