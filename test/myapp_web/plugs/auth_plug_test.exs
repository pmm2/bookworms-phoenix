defmodule MyappWeb.AuthPlugTest do
  use MyappWeb.ConnCase, async: true

  alias Myapp.Accounts.User
  alias Myapp.Repo
  alias MyappWeb.AuthPlug

  describe "fetch_current_user" do
    test "assigns nil when no user_id in session", %{conn: conn} do
      conn = conn |> Phoenix.ConnTest.init_test_session(%{}) |> AuthPlug.fetch_current_user([])

      assert conn.assigns.current_user == nil
    end

    test "assigns user when user_id exists in session", %{conn: conn} do
      user = insert_user!()

      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(%{})
        |> Plug.Conn.put_session(:user_id, user.id)
        |> AuthPlug.fetch_current_user([])

      assert conn.assigns.current_user.id == user.id
    end

    test "clears session and assigns nil when user no longer exists", %{conn: conn} do
      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(%{})
        |> Plug.Conn.put_session(:user_id, 99_999)
        |> AuthPlug.fetch_current_user([])

      assert conn.assigns.current_user == nil
    end
  end

  describe "require_authenticated" do
    test "allows through when current_user is set", %{conn: conn} do
      user = insert_user!()
      conn =
        conn
        |> Phoenix.ConnTest.bypass_through(MyappWeb.Router, :browser)
        |> get(~p"/")
        |> Plug.Conn.assign(:current_user, user)
        |> AuthPlug.require_authenticated([])

      refute conn.halted
    end

    test "redirects to login when current_user is nil", %{conn: conn} do
      conn =
        conn
        |> Phoenix.ConnTest.bypass_through(MyappWeb.Router, :browser)
        |> get(~p"/")
        |> Plug.Conn.assign(:current_user, nil)
        |> AuthPlug.require_authenticated([])

      assert conn.halted
      assert redirected_to(conn) == ~p"/login"
    end
  end

  describe "redirect_if_authenticated" do
    test "redirects to clubs when current_user is set", %{conn: conn} do
      user = insert_user!()
      conn = conn |> Plug.Conn.assign(:current_user, user) |> AuthPlug.redirect_if_authenticated([])

      assert conn.halted
      assert redirected_to(conn) == ~p"/clubs"
    end

    test "allows through when current_user is nil", %{conn: conn} do
      conn = conn |> Plug.Conn.assign(:current_user, nil) |> AuthPlug.redirect_if_authenticated([])

      refute conn.halted
    end
  end

  defp insert_user! do
    %User{}
    |> User.changeset(%{
      email: "plug-#{System.unique_integer([:positive])}@example.com",
      name: "Plug User",
      google_uid: "google-#{System.unique_integer([:positive])}"
    })
    |> Repo.insert!()
  end
end
