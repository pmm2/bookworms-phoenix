defmodule Myapp.Repo.Migrations.CreateBookClubs do
  use Ecto.Migration

  def change do
    create table(:book_clubs) do
      add :name, :string, null: false
      add :invite_code, :string, null: false
      add :owner_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:book_clubs, [:invite_code])
    create index(:book_clubs, [:owner_id])

    create table(:book_club_memberships) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :book_club_id, references(:book_clubs, on_delete: :delete_all), null: false
      add :role, :string, null: false, default: "member"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:book_club_memberships, [:user_id, :book_club_id])
    create index(:book_club_memberships, [:book_club_id])
  end
end
