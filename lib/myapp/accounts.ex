defmodule Myapp.Accounts do
  @moduledoc """
  Context for user accounts and authentication.
  """

  alias Myapp.Repo
  alias Myapp.Accounts.User

  @doc """
  Finds or creates a user from Google OAuth info.
  """
  def get_or_create_user_from_auth(auth) do
    attrs = %{
      email: auth.info.email,
      name: auth.info.name || auth.info.email,
      google_uid: auth.uid,
      avatar_url: auth.info.image
    }

    case Repo.get_by(User, google_uid: auth.uid) do
      nil ->
        Repo.insert!(User.changeset(%User{}, attrs))

      user ->
        Repo.update!(User.changeset(user, attrs))
    end
  end

  @doc """
  Gets a user by ID.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a user by ID, returns nil if not found.
  """
  def get_user(id), do: Repo.get(User, id)
end
