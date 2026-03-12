defmodule Myapp.Clubs.ReadingSession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reading_sessions" do
    belongs_to :user, Myapp.Accounts.User
    belongs_to :book_club, Myapp.Clubs.BookClub
    field :book_name, :string
    field :amount, :integer
    field :unit, :string
    field :session_date, :date

    timestamps(type: :utc_datetime)
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id, :book_club_id, :book_name, :amount, :unit, :session_date])
    |> validate_required([:user_id, :book_club_id, :book_name, :amount, :unit, :session_date])
    |> validate_inclusion(:unit, ~w(pages minutes))
    |> validate_number(:amount, greater_than: 0)
    |> validate_length(:book_name, min: 1)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:book_club_id)
  end
end
