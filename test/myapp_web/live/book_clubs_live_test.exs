defmodule MyappWeb.BookClubsLiveTest do
  use MyappWeb.LiveViewCase, async: true

  test "displays book clubs when logged in", %{conn: conn} do
    user = insert_user!()
    conn = log_in_user(conn, user)

    {:ok, view, html} = live(conn, ~p"/clubs")

    assert html =~ "My book clubs"
    assert html =~ "Sci-Fi Nerds"
    assert has_element?(view, "button", "Join club")
    assert has_element?(view, "button", "Create club")
  end

  test "redirects to login when not logged in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/login"}}} = live(conn, ~p"/clubs")
  end

  test "opens join modal when clicking Join club", %{conn: conn} do
    user = insert_user!()
    conn = log_in_user(conn, user)

    {:ok, view, _html} = live(conn, ~p"/clubs")

    view |> element("button", "Join club") |> render_click()
    assert has_element?(view, "#join-club-form")
  end

  test "opens create modal when clicking Create club", %{conn: conn} do
    user = insert_user!()
    conn = log_in_user(conn, user)

    {:ok, view, _html} = live(conn, ~p"/clubs")

    view |> element("button", "Create club") |> render_click()
    assert has_element?(view, "#create-club-form")
  end

  test "submits join form", %{conn: conn} do
    user = insert_user!()
    conn = log_in_user(conn, user)

    {:ok, view, _html} = live(conn, ~p"/clubs")
    view |> element("button", "Join club") |> render_click()

    view
    |> form("#join-club-form", %{join: %{invite_code: "JOIN123"}})
    |> render_submit()

    assert render(view) =~ "My book clubs"
  end

  test "submits create form", %{conn: conn} do
    user = insert_user!()
    conn = log_in_user(conn, user)

    {:ok, view, _html} = live(conn, ~p"/clubs")
    view |> element("button", "Create club") |> render_click()

    view
    |> form("#create-club-form", %{create: %{name: "New Club"}})
    |> render_submit()

    assert render(view) =~ "My book clubs"
  end

  defp insert_user! do
    %Myapp.Accounts.User{}
    |> Myapp.Accounts.User.changeset(%{
      email: "clubs-#{System.unique_integer([:positive])}@example.com",
      name: "Clubs User",
      google_uid: "google-#{System.unique_integer([:positive])}"
    })
    |> Myapp.Repo.insert!()
  end
end
