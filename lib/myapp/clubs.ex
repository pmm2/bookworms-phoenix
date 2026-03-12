defmodule Myapp.Clubs do
  @moduledoc """
  Context for book clubs and memberships.
  """

  import Ecto.Query
  alias Myapp.Repo

  alias Myapp.Accounts.User
  alias Myapp.Clubs.BookClub
  alias Myapp.Clubs.BookClubMembership
  alias Myapp.Clubs.ReadingSession

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
  Lists reading sessions for a club, newest first.
  """
  def list_sessions(%BookClub{id: club_id}) do
    ReadingSession
    |> where([s], s.book_club_id == ^club_id)
    |> order_by([s], desc: s.session_date, desc: s.inserted_at)
    |> preload(:user)
    |> Repo.all()
    |> Enum.map(&to_feed_entry/1)
  end

  @doc """
  Returns the monthly leaderboard for a club.
  Uses current month. Rankings: pages + minutes/2 (1 page ≈ 2 min).
  """
  def list_leaderboard(%BookClub{id: club_id}, year \\ nil, month \\ nil) do
    now = Date.utc_today()
    year = year || now.year
    month = month || now.month
    start_date = Date.new!(year, month, 1)
    end_date = Date.end_of_month(start_date)

    ReadingSession
    |> where([s], s.book_club_id == ^club_id)
    |> where([s], s.session_date >= ^start_date and s.session_date <= ^end_date)
    |> preload(:user)
    |> Repo.all()
    |> Enum.group_by(& &1.user_id, & &1)
    |> Enum.map(fn {user_id, sessions} ->
      user = hd(sessions).user

      {total_pages, total_minutes} =
        Enum.reduce(sessions, {0, 0}, fn s, {pages, mins} ->
          case s.unit do
            "pages" -> {pages + s.amount, mins}
            "minutes" -> {pages, mins + s.amount}
            _ -> {pages, mins}
          end
        end)

      score = total_pages + div(total_minutes, 2)

      %{
        user_id: user_id,
        user_name: user.name,
        total_pages: total_pages,
        total_minutes: total_minutes,
        score: score
      }
    end)
    |> Enum.sort_by(& &1.score, :desc)
    |> Enum.with_index(1)
    |> Enum.map(fn {entry, rank} ->
      entry
      |> Map.put(:rank, rank)
      |> Map.put(:badge, if(rank == 1, do: :winner, else: nil))
    end)
  end

  @doc """
  Logs a reading session for a user in a club.
  """
  def log_session(%User{} = user, %BookClub{id: club_id}, attrs) do
    unless membership?(%BookClub{id: club_id}, user) do
      {:error, :not_member}
    else
      attrs =
        attrs
        |> Map.put("user_id", user.id)
        |> Map.put("book_club_id", club_id)

      %ReadingSession{}
      |> ReadingSession.changeset(attrs)
      |> Repo.insert()
    end
  end

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

  defp to_feed_entry(%ReadingSession{} = s) do
    %{
      id: s.id,
      user_name: s.user.name,
      book_name: s.book_name,
      amount: s.amount,
      unit: s.unit,
      session_date: s.session_date,
      inserted_at: relative_time(s.inserted_at)
    }
  end

  defp relative_time(datetime) do
    now = DateTime.utc_now()
    diff_sec = DateTime.diff(now, datetime, :second)

    cond do
      diff_sec < 60 -> "Just now"
      diff_sec < 3600 -> "#{div(diff_sec, 60)} min ago"
      diff_sec < 86_400 -> "#{div(diff_sec, 3600)} hours ago"
      diff_sec < 172_800 -> "Yesterday"
      diff_sec < 604_800 -> "#{div(diff_sec, 86_400)} days ago"
      diff_sec < 2_592_000 -> "#{div(diff_sec, 604_800)} week(s) ago"
      true -> Calendar.strftime(datetime, "%b %d, %Y")
    end
  end
end
