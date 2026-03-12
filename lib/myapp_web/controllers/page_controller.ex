defmodule MyappWeb.PageController do
  use MyappWeb, :controller

  def redirect_to_login(conn, _params) do
    redirect(conn, to: ~p"/login")
  end
end
