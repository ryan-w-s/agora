defmodule Agora.Forum.Thread do
  @moduledoc """
  Represents a Forum Thread, which can contain comments.
  Also belongs to a Topic and a User.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Agora.Accounts.User
  alias Agora.Forum.Topic

  @derive {Jason.Encoder,
           only: [:id, :title, :body, :topic_id, :user_id, :inserted_at, :updated_at]}
  schema "threads" do
    field :title, :string
    field :body, :string

    belongs_to :user, User
    belongs_to :topic, Topic

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(thread, attrs) do
    thread
    |> cast(attrs, [:title, :body, :user_id, :topic_id])
    |> validate_required([:title, :body, :user_id, :topic_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:topic)
  end
end
