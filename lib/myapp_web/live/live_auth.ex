defmodule MyappWeb.LiveAuth do
  @moduledoc """
  On-mount hooks for LiveView authentication.
  """

  import Phoenix.Component
  import Phoenix.LiveView

  alias Myapp.Accounts

  use Phoenix.VerifiedRoutes,
    endpoint: MyappWeb.Endpoint,
    router: MyappWeb.Router,
    statics: MyappWeb.static_paths()

  def on_mount(:default, _params, session, socket) do
    {:cont,
     socket
     |> assign_current_user(session)}
  end

  def on_mount(:require_authenticated, _params, session, socket) do
    socket = assign_current_user(socket, session)

    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt,
       socket
       |> put_flash(:error, "You must sign in to access this page.")
       |> redirect(to: ~p"/login")}
    end
  end

  def on_mount(:redirect_if_authenticated, _params, session, socket) do
    socket = assign_current_user(socket, session)

    if socket.assigns[:current_user] do
      {:halt, redirect(socket, to: ~p"/clubs")}
    else
      {:cont, socket}
    end
  end

  defp assign_current_user(socket, session) do
    user_id = session["user_id"] || session[:user_id]

    case user_id do
      nil ->
        assign(socket, :current_user, nil)

      user_id ->
        assign(socket, :current_user, Accounts.get_user(user_id))
    end
  end
end
