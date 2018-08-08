defmodule U2FEx.Utils.ChallengeStore do
  @moduledoc """
  ETS based short-term store to keep challenges.
  """

  use GenServer
  require Logger

  @ets_table_name :u2fex_challenge_store

  #########################
  # GenServer Boilerplate #
  #########################

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    ets_table = :ets.new(@ets_table_name, [])
    {:ok, ets_table}
  end

  ##############
  # Public API #
  ##############

  def handle_call({:store_challenge, username, challenge}, _from, state) do
    case store_challenge(state, username, challenge) do
      :ok ->
        {:reply, :ok, state}
      {:error, retval} ->
        Logger.error("Failed to store challenge for U2FEx. Reason: #{Atom.to_string(retval)}")
        {:error, retval}
    end
  end
  def handle_call({:remove_challenge, username}, _from, state) do
    case remove_challenge(state, username) do
      {:ok, challenge} ->
        {:reply, challenge, state}
      {:error, retval} ->
        Logger.error("Failed to retrieve challenge for U2FEx. Reason: #{Atom.to_string(retval)}")
        {:error, retval}
    end
  end

  def handle_cast({:store_challenge, username, challenge}, _from, state) do
    case store_challenge(state, username, challenge) do
      :ok ->
        {:noreply, state}
      {:error, retval} ->
        Logger.error("Failed to store challenge for U2FEx. Reason: #{Atom.to_string(retval)}")
        {:noreply, state}
    end
  end

  ######################################
  # Internal API for challenge storage #
  ######################################

  @spec store_challenge(table :: atom(), username :: String.t(), challenge :: String.t()) :: :ok | {:error, atom}
  defp store_challenge(table, username, challenge) when is_binary(username) and is_binary(challenge) do
    case :ets.insert(table, {username, challenge}) do
      true ->
        :ok
    end
  end

  @spec remove_challenge(table :: atom(), username :: String.t()) :: {:ok, String.t()} | {:error, atom}
  defp remove_challenge(table, username) when is_binary(username) do
    case :ets.lookup(table, username) do
      [{_user, challenge}] ->
        {:ok, challenge}
      [{_user, challenge} | _rest] ->
        {:ok, challenge}
      [] ->
        {:error, :no_challenge_found}
    end
  end
end
