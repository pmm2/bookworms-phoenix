defmodule Myapp.ClubsTest do
  use Myapp.DataCase, async: true

  alias Myapp.Accounts.User
  alias Myapp.Clubs
  alias Myapp.Repo

  describe "create_club/2" do
    test "creates a club and adds owner as member", %{} do
      user = insert_user!()

      assert {:ok, club} = Clubs.create_club(user, "Test Club")
      assert club.name == "Test Club"
      assert String.length(club.invite_code) == 6
      assert club.owner_id == user.id

      assert Clubs.membership?(club, user)
    end

    test "returns error for empty name", %{} do
      user = insert_user!()
      assert {:error, :name_required} = Clubs.create_club(user, "")
      assert {:error, :name_required} = Clubs.create_club(user, "   ")
    end
  end

  describe "join_club/2" do
    test "joins user to club by invite code", %{} do
      owner = insert_user!()
      {:ok, club} = Clubs.create_club(owner, "Join Test")
      joiner = insert_user!()

      assert {:ok, joined_club} = Clubs.join_club(joiner, club.invite_code)
      assert joined_club.id == club.id
      assert Clubs.membership?(club, joiner)
    end

    test "returns error when invite code not found", %{} do
      user = insert_user!()
      assert {:error, :not_found} = Clubs.join_club(user, "INVALID")
    end

    test "returns error when already a member", %{} do
      user = insert_user!()
      {:ok, club} = Clubs.create_club(user, "My Club")

      assert {:error, :already_member} = Clubs.join_club(user, club.invite_code)
    end

    test "returns error for empty invite code", %{} do
      user = insert_user!()
      assert {:error, :invite_code_required} = Clubs.join_club(user, "")
    end
  end

  describe "list_clubs_for_user/1" do
    test "returns only clubs user is a member of", %{} do
      user = insert_user!()
      {:ok, club1} = Clubs.create_club(user, "Club 1")
      other = insert_user!()
      {:ok, _club2} = Clubs.create_club(other, "Club 2")

      clubs = Clubs.list_clubs_for_user(user)
      assert length(clubs) == 1
      assert hd(clubs).name == "Club 1"
      assert hd(clubs).id == club1.id
    end
  end

  describe "log_session/3" do
    test "creates a reading session for a member", %{} do
      user = insert_user!()
      {:ok, club} = Clubs.create_club(user, "Reading Club")

      attrs = %{
        "book_name" => "Dune",
        "amount" => "50",
        "unit" => "pages",
        "session_date" => Date.utc_today() |> Date.to_iso8601()
      }

      assert {:ok, session} = Clubs.log_session(user, club, attrs)
      assert session.book_name == "Dune"
      assert session.amount == 50
      assert session.unit == "pages"
      assert session.user_id == user.id
      assert session.book_club_id == club.id
    end

    test "returns error when user is not a member", %{} do
      owner = insert_user!()
      {:ok, club} = Clubs.create_club(owner, "Private Club")
      non_member = insert_user!()

      attrs = %{
        "book_name" => "Dune",
        "amount" => "50",
        "unit" => "pages",
        "session_date" => Date.utc_today() |> Date.to_iso8601()
      }

      assert {:error, :not_member} = Clubs.log_session(non_member, club, attrs)
    end
  end

  describe "list_sessions/1" do
    test "returns sessions for club ordered newest first", %{} do
      user = insert_user!()
      {:ok, club} = Clubs.create_club(user, "Feed Club")

      Clubs.log_session(user, club, %{
        "book_name" => "First",
        "amount" => "10",
        "unit" => "pages",
        "session_date" => Date.add(Date.utc_today(), -2) |> Date.to_iso8601()
      })

      Clubs.log_session(user, club, %{
        "book_name" => "Second",
        "amount" => "20",
        "unit" => "minutes",
        "session_date" => Date.utc_today() |> Date.to_iso8601()
      })

      sessions = Clubs.list_sessions(club)
      assert length(sessions) == 2
      assert hd(sessions).book_name == "Second"
      assert hd(sessions).user_name == user.name
    end
  end

  describe "list_leaderboard/1" do
    test "returns members ranked by reading this month", %{} do
      user1 = insert_user!()
      user2 = insert_user!()
      {:ok, club} = Clubs.create_club(user1, "Leader Club")
      Clubs.join_club(user2, club.invite_code)

      Clubs.log_session(user1, club, %{
        "book_name" => "Book A",
        "amount" => "100",
        "unit" => "pages",
        "session_date" => Date.utc_today() |> Date.to_iso8601()
      })

      Clubs.log_session(user2, club, %{
        "book_name" => "Book B",
        "amount" => "50",
        "unit" => "pages",
        "session_date" => Date.utc_today() |> Date.to_iso8601()
      })

      leaderboard = Clubs.list_leaderboard(club)
      assert length(leaderboard) == 2
      assert hd(leaderboard).user_name == user1.name
      assert hd(leaderboard).rank == 1
      assert hd(leaderboard).total_pages == 100
    end
  end

  defp insert_user! do
    %User{}
    |> User.oauth_changeset(%{
      email: "clubs-test-#{System.unique_integer([:positive])}@example.com",
      name: "Test User",
      google_uid: "google-#{System.unique_integer([:positive])}"
    })
    |> Repo.insert!()
  end
end
