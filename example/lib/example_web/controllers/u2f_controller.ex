defmodule ExampleWeb.U2FController do
  use ExampleWeb, :controller

  alias Example.Users
  alias Example.Users.U2FKey
  alias U2FEx.KeyMetadata

  def process(conn, %{"route" => route} = params) do
    apply(__MODULE__, String.to_atom(route), [conn, params])
  end

  # TODO(ian): Add docs about how to use.
  @doc """
  """
  def start_registration(conn, _params) do
    user_id = conn.params.user_id

    with registration_data <- U2FEx.start_registration(user_id) do
      conn
      |> json(registration_data)
    end
  end

  # TODO(ian): Add docs about how to use.
  @doc """
  """
  def finish_registration(conn, device_response) do
    user_id = conn.params.user_id

    with {:ok, %KeyMetadata{} = key_metadata} <-
           U2FEx.finish_registration(user_id, device_response),
         :ok <- store_key_data(user_id, key_metadata) do
      conn
      |> json(%{"success" => true})
    else
      _ -> json(conn, %{"success" => false})
    end
  end

  # TODO(ian): Add docs about how to use.
  @doc """
  """
  def start_authentication(conn, _params) do
    with {:ok, %{} = sign_request} <- U2FEx.start_authentication(conn.params.user_id) do
      conn
      |> json(sign_request)
    end
  end

  # TODO(ian): Add docs about how to use.
  @doc """
  """
  def finish_authentication(conn, device_response) do
    with :ok <- U2FEx.finish_authentication(conn.params.user_id, device_response) do
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
end
