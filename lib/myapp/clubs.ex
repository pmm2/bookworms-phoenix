defmodule Myapp.Clubs do
  @moduledoc """
  Context for book clubs and memberships.
  """

  import Ecto.Query
  alias Myapp.Repo

  alias Myapp.Accounts.User
  alias Myapp.Clubs.BookClub
  alias Myapp.Clubs.BookClubMembership

  @invite_code_length 6
  @invite_code_chars "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" |> String.graphemes()

  @doc """
  Creates a book club and adds the owner as a member.
  """
  def create_club(%User{} = owner, name) when is_binary(name) do
    name = String.trim(name)

    if name == "" do
      {:error, :name_required}
    else
      invite_code = generate_invite_code()

      %BookClub{}
      |> BookClub.changeset(%{
        name: name,
        invite_code: invite_code,
        owner_id: owner.id
      })
      |> Repo.insert()
      |> case do
        {:ok, club} ->
          add_member!(club, owner, "owner")
          {:ok, Repo.preload(club, :owner)}

        error ->
          error
      end
    end
  end

  @doc """
  Joins a user to a club by invite code.
  Returns {:ok, club} or {:error, reason}.
  """
  def join_club(%User{} = user, invite_code) when is_binary(invite_code) do
    code = String.trim(invite_code) |> String.upcase()

    if code == "" do
      {:error, :invite_code_required}
    else
      case Repo.get_by(BookClub, invite_code: code) do
        nil ->
          {:error, :not_found}

        club ->
          if membership?(club, user) do
            {:error, :already_member}
          else
            case add_member(club, user, "member") do
              {:ok, _} -> {:ok, Repo.preload(club, :owner)}
              error -> error
            end
          end
      end
    end
  end

  @doc """
  Lists all clubs the user is a member of.
  """
  def list_clubs_for_user(%User{id: user_id}) do
    BookClub
    |> join(:inner, [bc], m in BookClubMembership, on: m.book_club_id == bc.id)
    |> where([bc, m], m.user_id == ^user_id)
    |> preload([bc], [:owner, :memberships])
    |> Repo.all()
    |> Enum.map(&enrich_club/1)
  end

  @doc """
  Gets a club by ID.
  """
  def get_club!(id), do: Repo.get!(BookClub, id) |> Repo.preload(:owner)

  @doc """
  Gets a club by ID, returns nil if not found.
  """
  def get_club(id), do: Repo.get(BookClub, id) |> maybe_preload_owner()

  @doc """
  Checks if the user is a member of the club.
  """
  def membership?(%BookClub{id: club_id}, %User{id: user_id}) do
    Repo.exists?(
      from m in BookClubMembership,
        where: m.book_club_id == ^club_id and m.user_id == ^user_id
    )
  end

  defp add_member(%BookClub{} = club, %User{} = user, role) do
    %BookClubMembership{}
    |> BookClubMembership.changeset(%{
      book_club_id: club.id,
      user_id: user.id,
      role: role
    })
    |> Repo.insert()
  end

  defp add_member!(club, user, role) do
    {:ok, membership} = add_member(club, user, role)
    membership
  end

  defp generate_invite_code do
    code =
      for _ <- 1..@invite_code_length,
          do: Enum.random(@invite_code_chars),
          into: ""

    if Repo.exists?(from bc in BookClub, where: bc.invite_code == ^code) do
      generate_invite_code()
    else
      code
    end
  end

  defp enrich_club(club) do
    member_count = length(club.memberships)

    club
    |> Ecto.Changeset.change(%{})
    |> Ecto.Changeset.force_change(:member_count, member_count)
    |> Ecto.Changeset.force_change(:last_activity, "Recently")
    |> Ecto.Changeset.apply_changes()
  end

  defp maybe_preload_owner(nil), do: nil
  defp maybe_preload_owner(club), do: Repo.preload(club, :owner)
end
