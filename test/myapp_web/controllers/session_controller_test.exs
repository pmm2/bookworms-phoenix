defmodule MyappWeb.SessionControllerTest do
  use MyappWeb.ConnCase, async: true

  alias Myapp.Accounts

  describe "POST /session" do
    test "redirects to clubs when email and password are valid", %{conn: conn} do
      {:ok, user} =
        Accounts.register_user(%{
          "email" => "login@example.com",
          "name" => "Login User",
          "password" => "password123",
          "password_confirmation" => "password123"
        })

      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(%{})
        |> post(~p"/session", %{
          "user" => %{"email" => "login@example.com", "password" => "password123"}
        })

      assert redirected_to(conn) == ~p"/clubs"
      assert get_session(conn, :user_id) == user.id
    end

    test "redirects to login when password is invalid", %{conn: conn} do
      {:ok, _} =
        Accounts.register_user(%{
          "email" => "badpass@example.com",
          "name" => "User",
          "password" => "password123",
          "password_confirmation" => "password123"
        })

      conn =
        post(conn, ~p"/session", %{
          "user" => %{"email" => "badpass@example.com", "password" => "wrong"}
        })

      assert redirected_to(conn) == ~p"/login"
      refute get_session(conn, :user_id)
    end

    test "redirects to login when email does not exist", %{conn: conn} do
      conn =
        post(conn, ~p"/session", %{
          "user" => %{"email" => "unknown@example.com", "password" => "anything"}
        })

      assert redirected_to(conn) == ~p"/login"
      refute get_session(conn, :user_id)
    end
  end
end
