defmodule U2FEx.Utils.Crypto do
  @moduledoc """
  Houses crypto operations for U2F validation.
  """

  @doc """
  Hashes the input text using sha256
  """
  @spec sha256(input :: String.t()) :: binary()
  def sha256(input) when is_binary(input) do
    :crypto.hash(:sha256, input)
  end
end
