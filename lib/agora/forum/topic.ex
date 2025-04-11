defmodule Agora.Forum.Topic do
  @moduledoc """
  Represents a Forum Topic, which can contain threads and be nested.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :name, :string
    field :description, :string

    belongs_to :parent_topic, Agora.Forum.Topic, foreign_key: :parent_topic_id
    has_many :child_topics, Agora.Forum.Topic, foreign_key: :parent_topic_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:name, :description, :parent_topic_id])
    |> validate_required([:name, :description])
    |> validate_length(:name, min: 1)
    |> validate_length(:description, min: 1)
  end
end
