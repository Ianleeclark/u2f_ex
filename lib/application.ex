defmodule U2FEx.App do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(U2FEx.Utils.ChallengeStore, [])
    ]

    {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  end
end
