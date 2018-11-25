defmodule ExampleWeb.U2FController do
  use ExampleWeb, :controller

  alias Example.Users
  alias Example.Users.U2FKey
  alias U2FEx.KeyMetadata

  # TODO(ian): Add docs about how to use.
  @doc """
  """
  def start_registration(conn, _params) do
    with {:ok, registration_data} <- U2FEx.start_registration(get_user_id(conn)) do
      # TODO(ian): Update appId to not be b64 encoded
      output = %{
        registerRequests: [
          %{
            appId: Base.url_decode64!(registration_data.appId, padding: false),
            version: "U2F_V2",
            challenge: Base.url_decode64!(registration_data.challenge, padding: false)
          }
        ],
        registeredKeys: []
      }

      IO.inspect(output)

      conn
      |> json(output)
    end
  end

  # TODO(ian): Add docs about how to use.
  @doc """
  """
  def finish_registration(conn, device_response) do
    user_id = get_user_id(conn)
    # TODO(ian): Make U2FEx.finish_reg take a map instead of forcing this
    device_response = device_response |> Jason.encode!()

    with {:ok, %KeyMetadata{} = key_metadata} <-
           U2FEx.finish_registration(user_id, device_response),
         :ok <- store_key_data(user_id, key_metadata) do
      conn
      |> json(%{"success" => true})
    else
      error ->
        IO.inspect(error)
        conn |> put_status(:bad_request) |> json(%{"success" => false})
    end
  end

  # TODO(ian): Add docs about how to use.
  @doc """
  """
  def start_authentication(conn, _params) do
    with {:ok, %{} = sign_request} <- U2FEx.start_authentication(get_user_id(conn)) do
      conn
      |> json(sign_request)
    end
  end

  # TODO(ian): Add docs about how to use.
  @doc """
  """
  def finish_authentication(conn, device_response) do
    with :ok <- U2FEx.finish_authentication(get_user_id(conn), device_response |> Jason.encode!()) do
      conn
      |> json(%{"success" => true})
    else
      _ -> json(conn, %{"success" => false})
    end
  end

  @doc """
  Fill in with however you want to persist keys. See U2FEx.KeyMetadata struct for more info
  """
  @spec store_key_data(user_id :: any(), KeyMetadata.t()) :: :ok | {:error, any()}
  def store_key_data(user_id, key_metadata) do
    with {:ok, %U2FKey{}} <- Users.create_u2f_key(user_id, key_metadata) do
      :ok
    end
  end

  @spec get_user_id(Plug.Conn.t()) :: String.t()
  defp get_user_id(_conn) do
    "1"
  end
end
