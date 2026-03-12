defmodule Myapp.Clubs.BookClub do
  use Ecto.Schema
  import Ecto.Changeset

  schema "book_clubs" do
    field :name, :string
    field :invite_code, :string
    field :member_count, :integer, virtual: true
    field :last_activity, :string, virtual: true
    belongs_to :owner, Myapp.Accounts.User
    has_many :memberships, Myapp.Clubs.BookClubMembership
    has_many :members, through: [:memberships, :user]

    timestamps(type: :utc_datetime)
  end

  def changeset(book_club, attrs) do
    book_club
    |> cast(attrs, [:name, :invite_code, :owner_id])
    |> validate_required([:name, :invite_code, :owner_id])
    |> unique_constraint(:invite_code)
    |> foreign_key_constraint(:owner_id)
  end
end
