defmodule U2FEx.RegisteredKey do
  @moduledoc false
  @type b64_string() :: String.t()
  @type t :: %__MODULE__{
          version: String.t(),
          key_handle: String.t(),
          app_id: String.t(),
          transports: [map()]
        }

  @type stripped_to_map() :: %{
          required(:version) => String.t(),
          required(:key_handle) => b64_string,
          required(:app_id) => String.t(),
          optional(:transport) => [any()]
        }

  @required_keys [:version, :key_handle, :app_id, :transports]
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
      key_handle: key_handle,
      app_id: app_id,
      transports: transports
    )
  end

  @spec to_map(__MODULE__.t() | __MODULE__.stripped_to_map()) :: %{
          required(:version) => String.t(),
          required(:keyHandle) => b64_string,
          required(:appId) => String.t(),
          optional(:transports) => [any()]
        }
  def to_map(%{version: version, key_handle: kh, app_id: appId}) do
    %{version: version, keyHandle: kh, appId: appId}
  end

  def to_map(%{version: version, key_handle: kh, app_id: appId, transports: transports}) do
    %{version: version, keyHandle: kh, appId: appId, transports: transports}
  end

  def to_map(%__MODULE__{version: version, key_handle: kh, app_id: appId, transports: transports}) do
    %{version: version, keyHandle: kh, appId: appId, transports: transports}
  end
end
