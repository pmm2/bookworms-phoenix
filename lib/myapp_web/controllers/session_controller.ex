defmodule MyappWeb.SessionController do
  use MyappWeb, :controller

  alias Myapp.Accounts
  alias MyappWeb.AuthPlug

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        conn
        |> put_flash(:error, "Invalid email or password.")
        |> redirect(to: ~p"/login")

      user ->
        conn
        |> AuthPlug.log_in_user(user)
        |> put_flash(:info, "Welcome back, #{user.name}!")
        |> redirect(to: ~p"/clubs")
    end
  end

  def create(conn, _params) do
    conn
    |> put_flash(:error, "Email and password are required.")
    |> redirect(to: ~p"/login")
  end
end
