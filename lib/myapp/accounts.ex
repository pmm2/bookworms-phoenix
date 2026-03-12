defmodule Myapp.Accounts do
  @moduledoc """
  Context for user accounts and authentication.
  """

  alias Myapp.Repo
  alias Myapp.Accounts.User

  @doc """
  Registers a new user with email and password.
  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Authenticates a user by email and password.
  Returns the user if valid, nil otherwise.
  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: String.downcase(email))

    if user && user.password_hash && Bcrypt.verify_pass(password, user.password_hash) do
      user
    else
      Bcrypt.no_user_verify()
      nil
    end
  end

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
        Repo.insert!(User.oauth_changeset(%User{}, attrs))

      user ->
        Repo.update!(User.oauth_changeset(user, attrs))
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
