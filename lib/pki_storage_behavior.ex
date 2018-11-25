defmodule U2FEx.PKIStorageBehaviour do
  @moduledoc """
  This is a way for you to store the key metadata required by u2f_ex in any manner you choose.

  An example can be seen here:

  ```elixir
  defmodule App.PKIStorage do
    @behaviour U2FEx.PKIStorageBehaviour
    @moduledoc false
    import Ecto.Query

    alias App.U2FKeys

    @impl PKIStorageBehaviour
    def list_key_handles_for_user(user_id) do
      q =
      from(u in U2FKeys,
      where: u.id == ^user_id
      )

      q
      |> Repo.all()
      |> Enum.map(fn %U2FKeys{version: version, key_handle: key_handle, app_id: app_id} ->
        %{version: version, key_handle: key_handle, app_id: app_id}
      end)
    end
  end
  ```
  """

  @type b64_string :: String.t()

  @doc """
  """
  @callback list_key_handles_for_user(user_id :: String.t()) ::
              {:ok,
               [
                 %{
                   required(:version) => String.t(),
                   required(:key_handle) => b64_string(),
                   optional(:app_id) => String.t(),
                   optional(:transports) => [map]
                 }
               ]}

  @doc """
  """
  @callback get_public_key_for_user(user_id :: String.t(), key_handle :: b64_string()) ::
              {:ok, b64_string()} | {:error, :public_key_not_found}
end
