defmodule ExampleWeb.U2FController do
  use ExampleWeb, :controller

  alias Example.Users
  alias Example.Users.U2FKey
  alias U2FEx.KeyMetadata

  @doc """
  This is the first interaction in the u2f flow. We'll challenge the u2f token to
  provide a public key and sign our challenge (+ other info) proving their ownership
  of the corresponding private key.
  """
  def start_registration(conn, _params) do
    with {:ok, registration_data} <- U2FEx.start_registration(get_user_id(conn)) do
      IO.inspect(registration_data)

      conn
      |> json(registration_data)
    end
  end

  @doc """
  This is the second step of the registration where we'll store their key metadata for
  use later in the authentication portion of the flow.
  """
  def finish_registration(conn, device_response) do
    user_id = get_user_id(conn)

    with {:ok, %KeyMetadata{} = key_metadata} <-
           U2FEx.finish_registration(user_id, device_response),
         :ok <- store_key_data(user_id, key_metadata) do
      conn
      |> json(%{"success" => true})
    else
      _error ->
        conn |> put_status(:bad_request) |> json(%{"success" => false})
    end
  end

  @doc """
  Should the user be logging in, and they have a u2f key registered in our system, we
  should challenge that user to prove their identity and ownership of the u2f device.
  """
  def start_authentication(conn, _params) do
    with {:ok, sign_request} <- U2FEx.start_authentication(get_user_id(conn)) do
      conn
      |> json(sign_request)
    end
  end

  @doc """
  After the user has attempted to verify their identity, U2FEx will verify they actually who are
  they say they are. Once this step has exited successfully, then we can be reasonably assured the
  user is who they claim to be.
  """
  def finish_authentication(conn, device_response) do
    with :ok <- U2FEx.finish_authentication(get_user_id(conn), device_response) do
      conn
      |> json(%{"success" => true})
    else
      _err ->
        conn |> put_status(:bad_request) |> json(%{"success" => false})
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
