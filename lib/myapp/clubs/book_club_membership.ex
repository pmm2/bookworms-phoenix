defmodule Myapp.Clubs.BookClubMembership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "book_club_memberships" do
    belongs_to :user, Myapp.Accounts.User
    belongs_to :book_club, Myapp.Clubs.BookClub
    field :role, :string, default: "member"

    timestamps(type: :utc_datetime)
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:user_id, :book_club_id, :role])
    |> validate_required([:user_id, :book_club_id])
    |> validate_inclusion(:role, ~w(member owner))
    |> unique_constraint([:user_id, :book_club_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:book_club_id)
  end
end
