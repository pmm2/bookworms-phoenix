defmodule MyappWeb.AuthPlug do
  @moduledoc """
  Plugs for handling authentication.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias Myapp.Accounts

  use Phoenix.VerifiedRoutes,
    endpoint: MyappWeb.Endpoint,
    router: MyappWeb.Router,
    statics: MyappWeb.static_paths()

  def init(fun) when is_atom(fun), do: fun

  def call(conn, fun) do
    apply(__MODULE__, fun, [conn, []])
  end

  def fetch_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if user_id do
      case Accounts.get_user(user_id) do
        nil ->
          conn
          |> delete_session(:user_id)
          |> assign(:current_user, nil)

        user ->
          assign(conn, :current_user, user)
      end
    else
      assign(conn, :current_user, nil)
    end
  end

  def require_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must sign in to access this page.")
      |> redirect(to: ~p"/login")
      |> halt()
    end
  end

  def redirect_if_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: ~p"/clubs")
      |> halt()
    else
      conn
    end
  end

  def log_in_user(conn, user) do
    conn
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def log_out_user(conn) do
    conn
    |> configure_session(drop: true)
    |> delete_resp_cookie("_myapp_key")
  end
end
