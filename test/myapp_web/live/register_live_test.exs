defmodule MyappWeb.RegisterLiveTest do
  use MyappWeb.LiveViewCase, async: true

  alias Myapp.Repo
  alias Myapp.Accounts.User

  test "displays registration form", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/register")
    assert html =~ "Create your account"
    assert has_element?(view, "#register-form")
  end

  test "creates account and redirects to login", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/register")

    view
    |> form("#register-form", %{
      user: %{
        email: "newuser@example.com",
        name: "New User",
        password: "password123",
        password_confirmation: "password123"
      }
    })
    |> render_submit()

    assert_redirect(view, ~p"/login")

    user = Repo.get_by(User, email: "newuser@example.com")
    assert user != nil
    assert user.name == "New User"
    assert user.password_hash != nil
  end

  test "shows validation errors", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/register")

    html =
      view
      |> form("#register-form", %{
        user: %{
          email: "invalid",
          name: "",
          password: "short",
          password_confirmation: "nomatch"
        }
      })
      |> render_submit()

    assert html =~ "must be a valid email"
    assert html =~ "can&#39;t be blank"
    assert html =~ "at least 8"
    assert html =~ "does not match"
  end

  test "redirects to clubs when already logged in", %{conn: conn} do
    user =
      %User{}
      |> User.oauth_changeset(%{
        email: "loggedin@example.com",
        name: "Logged In",
        google_uid: "google-#{System.unique_integer([:positive])}"
      })
      |> Repo.insert!()

    conn = log_in_user(conn, user)
    assert {:error, {:redirect, %{to: "/clubs"}}} = live(conn, ~p"/register")
  end
end
