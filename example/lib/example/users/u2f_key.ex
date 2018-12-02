defmodule Example.Users.U2FKey do
  use Ecto.Schema
  import Ecto.Changeset

  alias Example.Users.User

  schema "u2f_keys" do
    field(:public_key, :string, size: 128, null: false)
    field(:key_handle, :string, size: 128, null: false)
    field(:version, :string, size: 10, null: false, default: "U2F_V2")
    field(:app_id, :string, null: false)
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
      case Base.url_decode64(value, padding: false) do
        {:ok, _result} ->
          []

        _ ->
          [{field, opts[:message] || "Invalid field #{field}. Expected b64 encoded string."}]
      end
    end)
  end
end
