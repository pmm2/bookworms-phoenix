defmodule Myapp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :google_uid, :string
    field :avatar_url, :string

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :password, :password_confirmation])
    |> validate_required([:email, :name, :password, :password_confirmation])
    |> validate_length(:password, min: 8, max: 72)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_confirmation(:password, required: true)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  def oauth_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :google_uid, :avatar_url])
    |> validate_required([:email, :name, :google_uid])
    |> unique_constraint(:google_uid)
    |> unique_constraint(:email)
  end

  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset

      password ->
        changeset
        |> put_change(:password_hash, Bcrypt.hash_pwd_salt(password))
        |> delete_change(:password)
    end
  end
end
