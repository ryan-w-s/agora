defmodule Agora.ForumFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Agora.Forum` context.
  """

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
end
