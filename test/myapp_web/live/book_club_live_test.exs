defmodule MyappWeb.BookClubLiveTest do
  use MyappWeb.LiveViewCase, async: true

  test "displays club detail when logged in", %{conn: conn} do
    user = insert_user!()
    conn = log_in_user(conn, user)

    {:ok, view, html} = live(conn, ~p"/clubs/1")

    assert html =~ "Sci-Fi Nerds"
    assert html =~ "Project Hail Mary"
    assert html =~ "March 2025 leaderboard"
    assert has_element?(view, "button", "Log reading")
  end

  test "redirects to login when not logged in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/clubs/1")
  end

  test "opens log modal when clicking Log reading", %{conn: conn} do
    user = insert_user!()
    conn = log_in_user(conn, user)

    {:ok, view, _html} = live(conn, ~p"/clubs/1")

    view |> element("button", "Log reading") |> render_click()
    assert has_element?(view, "#log-session-form")
  end

  test "submits log form", %{conn: conn} do
    user = insert_user!()
    conn = log_in_user(conn, user)

    {:ok, view, _html} = live(conn, ~p"/clubs/1")
    view |> element("button", "Log reading") |> render_click()

    view
    |> form("#log-session-form", %{
      session: %{
        book_name: "Test Book",
        amount: "50",
        unit: "pages",
        session_date: Date.utc_today() |> Date.to_iso8601()
      }
    })
    |> render_submit()

    assert render(view) =~ "Sci-Fi Nerds"
  end

  defp insert_user! do
    %Myapp.Accounts.User{}
    |> Myapp.Accounts.User.changeset(%{
      email: "club-#{System.unique_integer([:positive])}@example.com",
      name: "Club User",
      google_uid: "google-#{System.unique_integer([:positive])}"
    })
    |> Myapp.Repo.insert!()
  end
end
