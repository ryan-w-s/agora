defmodule Agora.ForumTest do
  use Agora.DataCase

  alias Agora.Forum

  describe "topics" do
    alias Agora.Forum.Topic

    import Agora.ForumFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_topics/0 returns all topics" do
      topic = topic_fixture()
      assert Forum.list_topics() == [topic]
    end

    test "get_topic!/1 returns the topic with given id" do
      topic = topic_fixture()
      assert Forum.get_topic!(topic.id) == topic
    end

    test "create_topic/1 with valid data creates a topic" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Topic{} = topic} = Forum.create_topic(valid_attrs)
      assert topic.name == "some name"
      assert topic.description == "some description"
    end

    test "create_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Forum.create_topic(@invalid_attrs)
    end

    test "update_topic/2 with valid data updates the topic" do
      topic = topic_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Topic{} = topic} = Forum.update_topic(topic, update_attrs)
      assert topic.name == "some updated name"
      assert topic.description == "some updated description"
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = Forum.update_topic(topic, @invalid_attrs)
      assert topic == Forum.get_topic!(topic.id)
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{}} = Forum.delete_topic(topic)
      assert_raise Ecto.NoResultsError, fn -> Forum.get_topic!(topic.id) end
    end

    test "change_topic/1 returns a topic changeset" do
      topic = topic_fixture()
      assert %Ecto.Changeset{} = Forum.change_topic(topic)
    end
  end
end
