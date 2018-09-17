defmodule ExampleWeb.U2fController do
  use ExampleWeb, :controller

  def register(conn, _params) do
    retval = %{
      appId: "https://localhost",
      registerRequests: [
        %{
          version: "U2F_V2",
          # TODO(ian): Call the u2f.generate_challenge() function here
          challenge: :crypto.strong_rand_bytes(32) |> Base.encode64(padding: false)
        }
      ],
      # TODO(ian): App should fetch these and then return.
      registeredKeys: []
    }

    conn
    |> json(retval)
  end
end
