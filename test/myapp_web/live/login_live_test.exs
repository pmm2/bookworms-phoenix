defmodule MyappWeb.LoginLiveTest do
  use MyappWeb.LiveViewCase, async: true

  test "displays sign in with Google link", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/login")

    assert html =~ "Sign in with Google"
    assert html =~ "Bookworms"
    assert has_element?(view, "a[href*='/auth/google']")
  end

  test "redirects to clubs when already logged in", %{conn: conn} do
    user = insert_user!()
    conn = log_in_user(conn, user)

    assert {:error, {:redirect, %{to: "/clubs"}}} = live(conn, ~p"/login")
  end

  defp insert_user! do
    %Myapp.Accounts.User{}
    |> Myapp.Accounts.User.changeset(%{
      email: "login-#{System.unique_integer([:positive])}@example.com",
      name: "Login User",
      google_uid: "google-#{System.unique_integer([:positive])}"
    })
    |> Myapp.Repo.insert!()
  end
end
