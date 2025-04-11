defmodule Agora.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :name, :string
      add :description, :text
      add :parent_topic_id, references(:topics, on_delete: :nilify_all), null: true

      timestamps(type: :utc_datetime)
    end
  end
end
