defmodule MyappWeb.LiveViewCase do
  @moduledoc """
  Test case for LiveView tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint MyappWeb.Endpoint

      import Plug.Conn
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest
      use MyappWeb, :verified_routes

      alias Myapp.Accounts
      alias Myapp.Accounts.User

      import MyappWeb.LiveViewCase, only: [log_in_user: 2]
    end
  end

  setup tags do
    Myapp.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Logs in a user and returns the updated conn.
  """
  def log_in_user(conn, user) do
    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_id, user.id)
  end
end
