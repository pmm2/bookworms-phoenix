defmodule Myapp.Repo.Migrations.AddPasswordToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_hash, :string
      modify :google_uid, :string, null: true
    end
  end
end
