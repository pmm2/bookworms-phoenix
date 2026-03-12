defmodule MyappWeb.BookClubLiveTest do
  use MyappWeb.LiveViewCase, async: true

  test "displays club detail when logged in", %{conn: conn} do
    user = insert_user!()
    {:ok, club} = Myapp.Clubs.create_club(user, "Test Club")
    conn = log_in_user(conn, user)

    {:ok, view, html} = live(conn, ~p"/clubs/#{club.id}")

    assert html =~ "Test Club"
    assert html =~ "leaderboard"
    assert has_element?(view, "button", "Log reading")
  end

  test "redirects to login when not logged in", %{conn: conn} do
    user = insert_user!()
    {:ok, club} = Myapp.Clubs.create_club(user, "Test")
    assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/clubs/#{club.id}")
  end

  test "redirects to clubs when user is not a member", %{conn: conn} do
    owner = insert_user!()
    {:ok, club} = Myapp.Clubs.create_club(owner, "Private Club")
    non_member = insert_user!()
    conn = log_in_user(conn, non_member)

    assert {:error, {:live_redirect, %{to: "/clubs"}}} = live(conn, ~p"/clubs/#{club.id}")
  end

  test "opens log modal when clicking Log reading", %{conn: conn} do
    user = insert_user!()
    {:ok, club} = Myapp.Clubs.create_club(user, "Log Club")
    conn = log_in_user(conn, user)

    {:ok, view, _html} = live(conn, ~p"/clubs/#{club.id}")

    view |> element("button", "Log reading") |> render_click()
    assert has_element?(view, "#log-session-form")
  end

  test "submits log form", %{conn: conn} do
    user = insert_user!()
    {:ok, club} = Myapp.Clubs.create_club(user, "Log Club")
    conn = log_in_user(conn, user)

    {:ok, view, _html} = live(conn, ~p"/clubs/#{club.id}")
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

    html = render(view)
    assert html =~ "Log Club"
    assert html =~ "Test Book"
    assert html =~ "50 pages"
  end

  defp insert_user! do
    %Myapp.Accounts.User{}
    |> Myapp.Accounts.User.oauth_changeset(%{
      email: "club-#{System.unique_integer([:positive])}@example.com",
      name: "Club User",
      google_uid: "google-#{System.unique_integer([:positive])}"
    })
    |> Myapp.Repo.insert!()
  end
end
