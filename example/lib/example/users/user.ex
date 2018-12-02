defmodule Example.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Example.Users.U2FKey

  schema "users" do
    field(:email, :string)
    field(:password, :string)
    has_many(:u2f_key, U2FKey)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
  end
end
