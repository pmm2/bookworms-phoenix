defmodule MyappWeb.LoginLiveTest do
  use MyappWeb.LiveViewCase, async: true

  test "displays sign in options", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/login")

    assert html =~ "Sign in with Google"
    assert html =~ "Sign in with email"
    assert html =~ "Bookworms"
    assert has_element?(view, "a[href*='/auth/google']")
    assert has_element?(view, "#login-form")
  end

  test "displays sign up link", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/login")
    assert html =~ "Sign up"
    assert html =~ ~p"/register"
  end

  test "redirects to clubs when already logged in", %{conn: conn} do
    user = insert_user!()
    conn = log_in_user(conn, user)

    assert {:error, {:redirect, %{to: "/clubs"}}} = live(conn, ~p"/login")
  end

  defp insert_user! do
    %Myapp.Accounts.User{}
    |> Myapp.Accounts.User.oauth_changeset(%{
      email: "login-#{System.unique_integer([:positive])}@example.com",
      name: "Login User",
      google_uid: "google-#{System.unique_integer([:positive])}"
    })
    |> Myapp.Repo.insert!()
  end
end
