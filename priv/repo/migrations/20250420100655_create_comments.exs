defmodule Agora.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :text
      add :user_id, references(:users, on_delete: :nothing)
      add :thread_id, references(:threads, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:user_id])
    create index(:comments, [:thread_id])
  end
end
