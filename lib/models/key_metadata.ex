defmodule U2FEx.KeyMetadata do
  @moduledoc """
  This represents the key metadata your application is expected to store. These values are B64 encoded and safe to store as-is.
  """

  @type t :: %__MODULE__{
          public_key: String.t(),
          key_handle: String.t(),
          app_id: String.t(),
          version: String.t()
        }

  @required_keys [:public_key, :key_handle, :app_id, :version]
  defstruct @required_keys

  @spec new(
          public_key :: String.t(),
          key_handle :: String.t(),
          app_id :: String.t(),
          version :: String.t()
        ) :: __MODULE__.t()
  def new(public_key, key_handle, app_id, version) do
    struct!(
      __MODULE__,
      public_key: public_key,
      key_handle: key_handle,
      app_id: app_id,
      version: version
    )
  end
end
