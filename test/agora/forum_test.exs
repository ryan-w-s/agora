defmodule Agora.ForumTest do
  use Agora.DataCase

  alias Agora.Forum
  alias Agora.AccountsFixtures

  describe "topics" do
    alias Agora.Forum.Topic

    import Agora.ForumFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_topics/0 returns all topics" do
      topic = topic_fixture()
      assert topic in Forum.list_topics()
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

    test "list_top_level_topics/0 returns only topics without parents" do
      parent_topic = topic_fixture()
      # Child topic linked to the parent
      _child_topic = topic_fixture(%{parent_topic_id: parent_topic.id})
      # Another independent top-level topic
      other_top_level_topic = topic_fixture()

      top_level_topics = Forum.list_top_level_topics()

      assert length(top_level_topics) == 2
      assert Enum.any?(top_level_topics, &(&1.id == parent_topic.id))
      assert Enum.any?(top_level_topics, &(&1.id == other_top_level_topic.id))
      # Ensure child_topic is NOT in the list
      refute Enum.any?(top_level_topics, &(&1.parent_topic_id == parent_topic.id))
    end
  end

  describe "threads" do
    alias Agora.Forum.Thread

    import Agora.ForumFixtures

    @invalid_attrs %{title: nil, body: nil}

    test "list_threads/0 returns all threads" do
      thread = thread_fixture()
      assert thread in Forum.list_threads()
    end

    test "get_thread!/1 returns the thread with given id" do
      thread = thread_fixture()
      # Fetch the thread with preloaded user to compare
      fetched_thread = Forum.get_thread!(thread.id)
      assert fetched_thread.id == thread.id
      # Check that user is loaded
      assert fetched_thread.user != nil
    end

    test "create_thread/1 with valid data creates a thread" do
      user = AccountsFixtures.user_fixture()
      topic = topic_fixture()

      valid_attrs = %{
        title: "some title",
        body: "some body",
        user_id: user.id,
        topic_id: topic.id
      }

      assert {:ok, %Thread{} = thread} = Forum.create_thread(valid_attrs)
      assert thread.title == "some title"
      assert thread.body == "some body"
      assert thread.user_id == user.id
      assert thread.topic_id == topic.id
    end

    test "create_thread/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Forum.create_thread(@invalid_attrs)
    end

    test "update_thread/2 with valid data updates the thread" do
      thread = thread_fixture()
      update_attrs = %{title: "some updated title", body: "some updated body"}

      assert {:ok, %Thread{} = thread} = Forum.update_thread(thread, update_attrs)
      assert thread.title == "some updated title"
      assert thread.body == "some updated body"
    end

    test "update_thread/2 with invalid data returns error changeset" do
      thread = thread_fixture()
      assert {:error, %Ecto.Changeset{}} = Forum.update_thread(thread, @invalid_attrs)
      # Compare specific fields instead of the whole struct
      fetched_thread_after_update = Forum.get_thread!(thread.id)
      assert fetched_thread_after_update.title == thread.title
      assert fetched_thread_after_update.body == thread.body
    end

    test "delete_thread/1 deletes the thread" do
      thread = thread_fixture()
      assert {:ok, %Thread{}} = Forum.delete_thread(thread)
      assert_raise Ecto.NoResultsError, fn -> Forum.get_thread!(thread.id) end
    end

    test "change_thread/1 returns a thread changeset" do
      thread = thread_fixture()
      assert %Ecto.Changeset{} = Forum.change_thread(thread)
    end
  end

  describe "comments" do
    alias Agora.Forum.Comment

    import Agora.ForumFixtures

    @invalid_attrs %{body: nil}

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Forum.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Forum.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      # Setup: Create required user and thread
      user = AccountsFixtures.user_fixture()
      thread = thread_fixture()

      # Add user_id and thread_id to valid_attrs
      valid_attrs = %{
        body: "some body",
        user_id: user.id,
        thread_id: thread.id
      }

      assert {:ok, %Comment{} = comment} = Forum.create_comment(valid_attrs)
      assert comment.body == "some body"
      # Also assert associations were set correctly
      assert comment.user_id == user.id
      assert comment.thread_id == thread.id
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Forum.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{body: "some updated body"}

      assert {:ok, %Comment{} = comment} = Forum.update_comment(comment, update_attrs)
      assert comment.body == "some updated body"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Forum.update_comment(comment, @invalid_attrs)
      assert comment == Forum.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Forum.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Forum.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Forum.change_comment(comment)
    end

    test "list_comments_for_thread/1 returns chronologically ordered comments for a specific thread" do
      # Setup: User, Topic, 2 Threads
      user = AccountsFixtures.user_fixture()
      topic = topic_fixture()
      thread1 = thread_fixture(%{user_id: user.id, topic_id: topic.id})
      thread2 = thread_fixture(%{user_id: user.id, topic_id: topic.id})

      # Create comments for thread1 (ensure different insertion times)
      comment1_t1 =
        comment_fixture(%{
          body: "First comment on thread 1",
          user_id: user.id,
          thread_id: thread1.id
        })

      # Simulate time passing
      Process.sleep(10)

      comment2_t1 =
        comment_fixture(%{
          body: "Second comment on thread 1",
          user_id: user.id,
          thread_id: thread1.id
        })

      # Create comment for thread2
      _comment1_t2 =
        comment_fixture(%{
          body: "First comment on thread 2",
          user_id: user.id,
          thread_id: thread2.id
        })

      # Fetch comments for thread1
      comments_for_thread1 = Forum.list_comments_for_thread(thread1.id)

      # Assertions
      assert length(comments_for_thread1) == 2
      assert Enum.map(comments_for_thread1, & &1.id) == [comment1_t1.id, comment2_t1.id]
      assert Enum.all?(comments_for_thread1, fn c -> c.thread_id == thread1.id end)
      # Check preload
      assert Enum.all?(comments_for_thread1, fn c -> c.user.id == user.id end)
    end
  end
end
