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

  @min_challenge_num_bytes 8

  @doc """
  Handles generating a challenge for the U2F device to verify against.
  """
  @spec generate_challenge(byte_len :: integer()) :: String.t()
  def generate_challenge(num_bytes \\ 32) when num_bytes > @min_challenge_num_bytes do
    num_bytes
    |> :crypto.strong_rand_bytes()
    |> b64_encode
  end

  @doc """
  Verifies the devices response against the challenge
  """
  @spec verify_signature(binary(), String.t(), [binary()]) :: :ok | {:error, atom()}
  def verify_signature(signature, challenge, public_key) when is_binary(signature) and is_binary(challenge) do
    case :crypto.verify(:ecdsa, :sha256, challenge, signature, public_key) do
      true ->
        :ok
      false ->
        {:error, :invalid_signature}
    end
  end

  @doc """
  Simple wrapper around Base.encode64(padding: false) because I always forget padding.
  """
  @spec b64_encode(data_to_encode :: String.t()) :: String.t()
  def b64_encode(data_to_encode) do
    data_to_encode
    |> Base.encode64(padding: false)
  end

  @doc """
  Simple wrapper around Base.decode64(padding: false) because I always forget padding.
  """
  @spec b64_decode(data_to_decode :: String.t()) :: String.t()
  def b64_decode(data_to_decode) do
    data_to_decode
    |> Base.decode64!(padding: false)
  end
end
