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
      assert Forum.get_topic!(topic.id).id == topic.id
    end

    test "create_topic/1 with valid data creates a topic" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Topic{} = topic} = Forum.create_topic(valid_attrs)
      assert topic.name == "some name"
      assert topic.description == "some description"
    end

    test "create_topic/1 with parent_topic_id creates a topic with a parent" do
      parent_topic = topic_fixture()

      valid_attrs = %{
        name: "Child Topic",
        description: "Child Desc",
        parent_topic_id: parent_topic.id
      }

      assert {:ok, %Topic{} = topic} = Forum.create_topic(valid_attrs)
      assert topic.name == "Child Topic"
      assert topic.parent_topic_id == parent_topic.id

      # Verify preload works after creation (fetch needed)
      fetched_topic = Forum.get_topic!(topic.id)
      assert fetched_topic.parent_topic.id == parent_topic.id
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

    test "update_topic/2 can add a parent_topic_id" do
      parent_topic = topic_fixture()
      # Initially no parent
      child_topic = topic_fixture()

      update_attrs = %{parent_topic_id: parent_topic.id}

      assert {:ok, %Topic{} = updated_child} = Forum.update_topic(child_topic, update_attrs)
      assert updated_child.parent_topic_id == parent_topic.id
    end

    test "update_topic/2 can remove a parent_topic_id" do
      parent_topic = topic_fixture()
      # Create a child that initially has the parent
      child_topic = topic_fixture(%{parent_topic_id: parent_topic.id})

      update_attrs = %{parent_topic_id: nil}

      assert {:ok, %Topic{} = updated_child} = Forum.update_topic(child_topic, update_attrs)
      assert updated_child.parent_topic_id == nil
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = Forum.update_topic(topic, @invalid_attrs)
      topic_after_attempted_update = Forum.get_topic!(topic.id)
      assert topic.name == topic_after_attempted_update.name
      assert topic.description == topic_after_attempted_update.description
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      topic_to_delete = Forum.get_topic!(topic.id)
      assert {:ok, %Topic{}} = Forum.delete_topic(topic_to_delete)
      assert_raise Ecto.NoResultsError, fn -> Forum.get_topic!(topic.id) end
    end

    test "change_topic/1 returns a topic changeset" do
      topic = topic_fixture()
      assert %Ecto.Changeset{} = Forum.change_topic(topic)
    end
  end
end
