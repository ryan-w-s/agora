defmodule Agora.Forum.Comment do
  @moduledoc """
  Comments, which are replies to threads.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Agora.Accounts.User
  alias Agora.Forum.Thread

  schema "comments" do
    field :body, :string

    belongs_to :user, User
    belongs_to :thread, Thread

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :user_id, :thread_id])
    |> validate_required([:body, :user_id, :thread_id])
  end
end
