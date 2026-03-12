defmodule Myapp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :google_uid, :string
    field :avatar_url, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :google_uid, :avatar_url])
    |> validate_required([:email, :name, :google_uid])
    |> unique_constraint(:google_uid)
    |> unique_constraint(:email)
  end
end
