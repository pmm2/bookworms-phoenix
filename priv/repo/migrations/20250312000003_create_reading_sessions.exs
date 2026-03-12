defmodule Myapp.Repo.Migrations.CreateReadingSessions do
  use Ecto.Migration

  def change do
    create table(:reading_sessions) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :book_club_id, references(:book_clubs, on_delete: :delete_all), null: false
      add :book_name, :string, null: false
      add :amount, :integer, null: false
      add :unit, :string, null: false
      add :session_date, :date, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:reading_sessions, [:book_club_id, :session_date])
    create index(:reading_sessions, [:book_club_id, :user_id])
  end
end
