defmodule Example.PKIStorage do
  @moduledoc false

  import Ecto.Query

  alias Example.Repo
  alias U2FEx.PKIStorageBehaviour
  alias Example.Users.U2FKey

  @behaviour U2FEx.PKIStorageBehaviour

  @impl PKIStorageBehaviour
  def list_key_handles_for_user(user_id) do
    q =
      from(u in U2FKey,
        where: u.user_id == ^user_id
      )

    x =
      q
      |> Repo.all()
      |> Enum.map(fn %U2FKey{version: version, key_handle: key_handle, app_id: app_id} ->
        %{version: version, key_handle: key_handle, app_id: app_id}
      end)

    {:ok, x}
  end

  @impl PKIStorageBehaviour
  def get_public_key_for_user(user_id, key_handle) do
    q = from(u in U2FKey, where: u.user_id == ^user_id and u.key_handle == ^key_handle)

    q
    |> Repo.one()
    |> case do
      nil -> {:error, :public_key_not_found}
      %U2FKey{public_key: public_key} -> {:ok, public_key}
    end
  end
end
