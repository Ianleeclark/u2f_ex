defmodule PhoenixU2F.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    opts = [strategy: :one_for_one, name: PhoenixU2F.Supervisor]
    Supervisor.start_link([], opts)
  end

  def config_change(changed, _new, removed) do
    PhoenixU2FWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
