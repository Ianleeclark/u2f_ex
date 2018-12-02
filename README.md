# U2fEx
[![CircleCI](https://circleci.com/gh/GrappigPanda/u2f_ex/tree/master.svg?style=svg)](https://circleci.com/gh/GrappigPanda/u2f_ex/tree/master)
[![Hex.pm](https://img.shields.io/hexpm/v/u2f_ex.svg)](https://hex.pm/packages/u2f_ex)
[HexDocs](https://hexdocs.pm/u2f_ex/api-reference.html)

A Pure Elixir implementation of the U2F Protocol.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `u2f_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:u2f_ex, "~> 0.3.0"}
  ]
end
```

### PKIStorage

In order to properly use this library, you're going to need to store metadata and public
keys for any user registering their U2F Token. However, u2f_ex will need to retrieve that 
metadata, so you're get to write a glorious new module implementing our storage behaviour.

Check out some example docs here: [PKIStorage Example](https://hexdocs.pm/ecto/Ecto.Repo.html#c:list_key_handles_for_user/1)

### Add A New SQL Table

This section assumes that you'll be using SQL as the primary storage mechanism for these keys,
but, if you plan on using something else, feel free to do so! Skip to the next section and, should 
you have any questions, [feel free to ask!](https://github.com/GrappigPanda/u2f_ex/issues)
First you'll want to create a model capable of representing the key metadata (you can steal the 
following code):

```elixir
defmodule Example.Users.U2FKey do
  use Ecto.Schema
  import Ecto.Changeset

  alias Example.Users.User

  schema "u2f_keys" do
    field(:public_key, :string, size: 128, null: false)
    field(:key_handle, :string, size: 128, null: false)
    field(:version, :string, size: 10, null: false, default: "U2F_V2")
    field(:app_id, :string, null: false)
    # NOTE: You'll need to update what table this references or change it to a normal field
    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:public_key, :key_handle, :version, :app_id, :user_id])
    |> validate_required([:public_key, :key_handle, :version, :app_id, :user_id])
    |> validate_b64_string(:public_key)
    |> validate_b64_string(:key_handle)
  end

  @doc false
  def validate_b64_string(changeset, field, opts \\ []) do
    validate_change(changeset, field, fn _, value ->
      case Base.decode64(value, padding: false) do
        {:ok, _result} ->
          []

        _ ->
          [{field, opts[:message] || "Invalid field #{field}. Expected b64 encoded string."}]
      end
    end)
  end
end
```

Finally, create and run the following migration:

```elixir
defmodule Example.Repo.Migrations.AddU2fKey do
  use Ecto.Migration

  def change do
    create table(:u2f_keys) do
      add(:public_key, :string, size: 128)
      add(:key_handle, :string, size: 128)
      add(:version, :string, size: 10, default: "U2F_V2")
      add(:app_id, :string)
      # NOTE: You'll need to update what table this references or change it to a normal field
      add(:user_id, references(:users))

      timestamps()
    end
  end
end
```

### Create a PKIStorage Module

Next you'll need to provide the library a way of storing and fetching metadata about stored U2F keys,
so you'll implement the [Storage Behaviour](https://hexdocs.pm/u2f_ex/U2FEx.PKIStorageBehaviour.html)

An example, that uses Ecto + SQL, will follow, but know that you can use whatever storage mechanism you 
want so long as you adhere to the contract.

```elixir
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
```

### Config Value

Next you'll need to update your configuration to set the PKIStorage model:

```elixir
config :u2f_ex,
    pki_storage: PKIStorage,
    app_id: "https://yoursite.com"
```
###### NOTE: The <app_id> should be your site.

### Create a Controller

You'll need a controller capable of handling these interactions:

```elixir
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
      output = %{
        registerRequests: [
          %{
            appId: registration_data.appId,
            padding: false,
            version: "U2F_V2",
            challenge: registration_data.challenge,
            padding: false
          }
        ],
        registeredKeys: []
      }

      conn
      |> json(output)
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
    with {:ok, %{} = sign_request} <- U2FEx.start_authentication(get_user_id(conn)) do
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
```

Moreover, you're going to need to add routes (feel free to change, but you need these four routes specifically).

```elixir
    post("/u2f/start_registration", U2FController, :start_registration)
    post("/u2f/finish_registration", U2FController, :finish_registration)
    post("/u2f/start_authentication", U2FController, :start_authentication)
    post("/u2f/finish_authentication", U2FController, :finish_authentication)
```

### Finally, finish up with some javascript

Vendor google's u2f-api-polyfill.js (Can be found [here](https://raw.githubusercontent.com/mastahyeti/u2f-api/master/u2f-api-polyfill.js) or [here](https://github.com/GrappigPanda/u2f_ex/blob/7223f588d03a6c472b1988de08428377f0a3dec9/example/assets/vendor/u2f-api-polyfill.js)).

Finally, you'll need to handle events for talking to the device. This assumes jquery, but it can be
easily swapped out and work in vanilla Javascript, React, Vue, &c.

```javascript
import $ from "jquery";

$(document).ready(() => {
  const appId = "https://localhost";
  const u2f = window.u2f;
  const post = (url, csrf, data) => {
    return $.ajax({
      url: url,
      type: "POST",
      dataType: "json",
      contentType: "application/json",
      data: JSON.stringify(data),
      beforeSend: xhr => {
        xhr.setRequestHeader("X-CSRF-TOKEN", csrf);
      }
    });
  };

  $("#register").click(() => {
    const csrf = $("meta[name='csrf-token']").attr("content");
    post("/u2f/start_registration", csrf).then(
      ({ appId, registerRequests, registeredKeys }) => {
        u2f.register(appId, registerRequests, registeredKeys, response => {
          post("/u2f/finish_registration", csrf, response)
            // NOTE: Handle finishing registration here
                .then(x => console.log("Finished Registration"));
        });
      },
      error => {
        console.error(error);
      }
    );
  });

  $("#sign").click(() => {
    const csrf = $("meta[name='csrf-token']").attr("content");
    post("/u2f/start_authentication", csrf).then(
      ({ challenge, registeredKeys }) => {
        u2f
          .sign(appId, challenge, registeredKeys, response1 => {
            post("/u2f/finish_authentication", csrf, response1).then(
              // NOTE: Handle finishing authentication here
              x => console.log("Finished Authentication")
            );
          });
      },
      error => {
        console.error(error);
      }
    );
  });
});
```
