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

  defp insert_user! do
    %User{}
    |> User.changeset(%{
      email: "clubs-test-#{System.unique_integer([:positive])}@example.com",
      name: "Test User",
      google_uid: "google-#{System.unique_integer([:positive])}"
    })
    |> Repo.insert!()
  end
end
