defmodule U2FEx.Utils do
  @moduledoc false

  @doc """
  Simple wrapper around Base.encode64(padding: false) because I always forget padding.
  """
  @spec b64_encode(data_to_encode :: String.t()) :: String.t()
  def b64_encode(data_to_encode) do
    data_to_encode
    |> Base.url_encode64(padding: false)
  end

  @doc """
  Simple wrapper around Base.decode64(padding: false) because I always forget padding.
  """
  @spec b64_decode(data_to_decode :: String.t()) :: String.t()
  def b64_decode(data_to_decode) do
    data_to_decode
    |> Base.url_decode64!(padding: false)
  end
end
