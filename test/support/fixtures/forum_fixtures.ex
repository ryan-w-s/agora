defmodule Agora.ForumFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Agora.Forum` context.
  """

  alias Agora.Forum
  alias Agora.AccountsFixtures

  @doc """
  Generate a topic.
  """
  def topic_fixture(attrs \\ %{}) do
    {:ok, topic} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Agora.Forum.create_topic()

    topic
  end

  @doc """
  Generate a thread.
  """
  def thread_fixture(attrs \\ %{}) do
    user = Map.get(attrs, :user) || AccountsFixtures.user_fixture()
    topic = Map.get(attrs, :topic) || topic_fixture()

    default_attrs = %{
      body: "some body",
      title: "some title",
      user_id: user.id,
      topic_id: topic.id
    }

    final_attrs = Map.merge(default_attrs, attrs)

    {:ok, thread} = Forum.create_thread(final_attrs)

    thread
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    # Ensure required associations exist if not provided
    user = Map.get(attrs, :user) || AccountsFixtures.user_fixture()
    thread = Map.get(attrs, :thread) || thread_fixture()

    # Define default attributes including the required IDs
    default_attrs = %{
      body: "some body",
      user_id: user.id,
      thread_id: thread.id
    }

    # Merge provided attrs, potentially overriding defaults
    final_attrs = Map.merge(default_attrs, attrs)

    # Create the comment
    {:ok, comment} = Forum.create_comment(final_attrs)

    comment
  end
end
