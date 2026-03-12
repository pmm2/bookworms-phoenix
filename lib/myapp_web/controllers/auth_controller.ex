defmodule MyappWeb.AuthController do
  use MyappWeb, :controller

  plug Ueberauth

  alias Myapp.Accounts
  alias MyappWeb.AuthPlug

  def request(conn, _params) do
    conn
  end

  def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Authentication failed: #{inspect(fails.errors)}")
    |> redirect(to: ~p"/login")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user = Accounts.get_or_create_user_from_auth(auth)

    conn
    |> AuthPlug.log_in_user(user)
    |> put_flash(:info, "Welcome back, #{user.name}!")
    |> redirect(to: ~p"/clubs")
  end

  def delete(conn, _params) do
    conn
    |> AuthPlug.log_out_user()
    |> put_flash(:info, "You have been signed out.")
    |> redirect(to: ~p"/login")
  end
end
