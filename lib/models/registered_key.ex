defmodule U2FEx.RegisteredKey do
  @moduledoc """
  Represents a key that's stored in a system. The `keyHandle` variable should map to the user's public key.
  """
  @type t :: %__MODULE__{
          version: String.t(),
          keyHandle: String.t(),
          transports: [map()],
          appId: String.t()
        }

  @required_keys [:version, :keyHandle, :transports, :appId]
  defstruct @required_keys
end
