defmodule MyappWeb.AuthControllerTest do
  use MyappWeb.ConnCase, async: true

  alias Myapp.Accounts.User
  alias Myapp.Repo

  describe "GET /auth/google" do
    test "redirects to Google OAuth", %{conn: conn} do
      conn = get(conn, ~p"/auth/google")
      assert redirected_to(conn) =~ "accounts.google.com"
    end
  end

  describe "GET /auth/google/callback" do
    test "creates user and redirects to clubs on success", %{conn: conn} do
      auth =
        build_ueberauth(uid: "google-999", email: "callback@example.com", name: "Callback User")

      conn =
        conn
        |> Phoenix.ConnTest.bypass_through(MyappWeb.Router, :browser)
        |> get(~p"/")
        |> Plug.Conn.assign(:ueberauth_auth, auth)
        |> MyappWeb.AuthController.callback(%{})

      assert redirected_to(conn) == ~p"/clubs"

      user = Repo.get_by(User, google_uid: "google-999")
      assert user.email == "callback@example.com"
    end

    test "redirects to login on ueberauth failure", %{conn: conn} do
      failure = %Ueberauth.Failure{
        provider: :google,
        strategy: Ueberauth.Strategy.Google,
        errors: []
      }

      conn =
        conn
        |> Phoenix.ConnTest.bypass_through(MyappWeb.Router, :browser)
        |> get(~p"/")
        |> Plug.Conn.assign(:ueberauth_failure, failure)
        |> MyappWeb.AuthController.callback(%{})

      assert redirected_to(conn) == ~p"/login"
    end
  end

  describe "DELETE /logout" do
    test "redirects to login with flash message", %{conn: conn} do
      user = insert_user!()

      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(%{})
        |> Plug.Conn.put_session(:user_id, user.id)
        |> delete(~p"/logout")

      assert redirected_to(conn) == ~p"/login"
    end
  end

  defp build_ueberauth(uid: uid, email: email, name: name) do
    %Ueberauth.Auth{
      uid: uid,
      provider: :google,
      info: %Ueberauth.Auth.Info{
        email: email,
        name: name,
        image: nil
      }
    }
  end

  defp insert_user! do
    %User{}
    |> User.changeset(%{
      email: "logout-#{System.unique_integer([:positive])}@example.com",
      name: "Logout User",
      google_uid: "google-#{System.unique_integer([:positive])}"
    })
    |> Repo.insert!()
  end
end
