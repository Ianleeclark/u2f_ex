defmodule U2FEx.SignResponse do
  @moduledoc """
  Represents an outgoing sign request. The U2F device will take this and prove their identity.
  """

  @type t :: %__MODULE__{
          key_handle: binary(),
          signature_data: binary(),
          client_data: binary()
        }

  alias U2FEx.Utils.Crypto

  @required_keys [:key_handle, :signature_data, :client_data]
  defstruct @required_keys

  @doc """
  Creates a new SignRequest. Should not be publicly called, see: from_json/1
  """
  @spec new(key_handle :: binary(), signature_data :: binary(), client_data :: binary()) ::
          __MODULE__.t()
  def new(key_handle, signature_data, client_data)
      when is_binary(key_handle) and is_binary(signature_data) and is_binary(client_data) do
    struct!(
      __MODULE__,
      key_handle: key_handle,
      signature_data: signature_data,
      client_data: client_data
    )
  end

  @doc """
  Creates a web-safe json blob
  """
  @spec to_json(__MODULE__.t()) :: String.t() | no_return
  def to_json(%__MODULE__{
        key_handle: key_handle,
        signature_data: signature_data,
        client_data: client_data
      }) do
    %{
      key_handle: key_handle,
      signature_data: signature_data |> Crypto.b64_encode(),
      client_data: client_data |> Crypto.b64_encode()
    }
    |> Jason.encode!()
  end
end
