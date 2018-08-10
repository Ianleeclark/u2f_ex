defmodule U2FExTest.Utils.ChallengeStoreTest do
  use ExUnit.Case

  alias U2FEx.Utils.{Crypto, ChallengeStore}

  @usernames ["ian", "lee", "clark"]
  @challenge_len 32

  ###################
  # Setup Functions #
  ###################

  def insert_test_challenges(_params) do
    @usernames
    |> Enum.map(fn username ->
      GenServer.call(
        ChallengeStore,
        {:store_challenge, username, Crypto.generate_challenge(@challenge_len)}
      )
    end)
    |> Enum.uniq()
    |> hd()
  end

  # start_supervised(ChallengeStore)
  setup_all :insert_test_challenges

  #########
  # Tests #
  #########

  describe "retrieving challenges" do
    test "retrieve username that exists succeeds" do
      {:ok, challenge} =
        response = GenServer.call(ChallengeStore, {:retrieve_challenge, hd(@usernames)})

      assert response
      assert is_binary(challenge)
    end

    test "retrieve username that doesnt exist fails" do
      {:error, errval} =
        response = GenServer.call(ChallengeStore, {:retrieve_challenge, "bruce-lee"})

      assert response
      assert errval == :no_challenge_found
    end
  end

  describe "removing challenges" do
    test "remove username that exists succeeds" do
      :ok = GenServer.call(ChallengeStore, {:remove_challenge, hd(Enum.reverse(@usernames))})
    end
  end

  describe "complete lifecycle tests" do
    test "Create challenge, store challenge, retrieve challenge, remove challenge" do
      challenge = Crypto.generate_challenge(32)
      username = "lee"

      :ok = GenServer.call(ChallengeStore, {:store_challenge, username, challenge})

      {:ok, retrieved_challenge} = GenServer.call(ChallengeStore, {:retrieve_challenge, username})
      assert challenge == retrieved_challenge

      :ok = GenServer.call(ChallengeStore, {:remove_challenge, username})

      {:error, errval} = GenServer.call(ChallengeStore, {:retrieve_challenge, username})
      assert errval == :no_challenge_found
    end
  end
end
