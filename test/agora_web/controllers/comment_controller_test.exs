defmodule AgoraWeb.CommentControllerTest do
  use AgoraWeb.ConnCase

  import Agora.ForumFixtures
  import Agora.AccountsFixtures

  alias Agora.Forum
  alias Agora.Accounts
  alias Agora.Repo

  @valid_comment_attrs %{body: "This is a test comment."}
  @invalid_comment_attrs %{body: ""}

  defp log_in_user(context) do
    register_and_log_in_user(context)
  end

  defp create_thread(%{user: user}) do
    topic = topic_fixture()
    thread = thread_fixture(%{user_id: user.id, topic_id: topic.id})
    %{thread: thread}
  end

  # Helper to create a moderator for tests
  defp moderator_fixture(attrs \\ %{}) do
    user = user_fixture(attrs)

    {:ok, moderator} =
      user
      |> Accounts.User.moderator_status_changeset(%{is_moderator: true})
      |> Repo.update()

    moderator
  end

  # Setup to create data needed for tests
  defp create_test_data(_) do
    user = user_fixture()
    topic = topic_fixture()
    thread = thread_fixture(%{user_id: user.id, topic_id: topic.id})
    comment = comment_fixture(%{user_id: user.id, thread_id: thread.id, body: "Original comment"})

    %{user: user, topic: topic, thread: thread, comment: comment}
  end

  setup [:log_in_user, :create_thread]

  describe "create comment" do
    test "redirects to thread show page when data is valid", %{conn: conn, thread: thread} do
      conn = post(conn, ~p"/threads/#{thread.id}/comments", comment: @valid_comment_attrs)

      assert redirected_to(conn) == ~p"/threads/#{thread.id}"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Comment posted successfully."

      # Verify comment was created
      comments = Forum.list_comments_for_thread(thread.id)
      assert length(comments) == 1
      assert hd(comments).body == @valid_comment_attrs.body
      assert hd(comments).user_id == conn.assigns.current_user.id
    end

    test "redirects with error flash when data is invalid", %{conn: conn, thread: thread} do
      conn = post(conn, ~p"/threads/#{thread.id}/comments", comment: @invalid_comment_attrs)

      assert redirected_to(conn) == ~p"/threads/#{thread.id}"
      flash_error = Phoenix.Flash.get(conn.assigns.flash, :error)
      assert flash_error =~ "Could not post comment."
      assert flash_error =~ "body: {\"can't be blank\""

      # Verify comment was *not* created
      comments = Forum.list_comments_for_thread(thread.id)
      assert Enum.empty?(comments)
    end
  end

  describe "edit comment" do
    setup [:create_test_data]

    test "user can access edit form for their own comment", %{conn: conn, user: user, thread: thread, comment: comment} do
      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/threads/#{thread.id}/comments/#{comment.id}/edit")

      assert html_response(conn, 200) =~ "Edit Comment"
      assert html_response(conn, 200) =~ "Original comment"
    end

    test "moderator can access edit form for any comment", %{conn: conn, thread: thread, comment: comment} do
      moderator = moderator_fixture()

      conn =
        conn
        |> log_in_user(moderator)
        |> get(~p"/threads/#{thread.id}/comments/#{comment.id}/edit")

      assert html_response(conn, 200) =~ "Edit Comment"
    end

    test "regular user cannot access edit form for another user's comment", %{conn: conn, thread: thread, comment: comment} do
      other_user = user_fixture()

      conn =
        conn
        |> log_in_user(other_user)
        |> get(~p"/threads/#{thread.id}/comments/#{comment.id}/edit")

      assert redirected_to(conn) == ~p"/threads/#{thread.id}"
      assert get_flash(conn, :error) =~ "not authorized"
    end
  end

  describe "update comment" do
    setup [:create_test_data]

    test "user can update their own comment", %{conn: conn, user: user, thread: thread, comment: comment} do
      conn =
        conn
        |> log_in_user(user)
        |> put(~p"/threads/#{thread.id}/comments/#{comment.id}", %{
          "comment" => %{"body" => "Updated comment text"}
        })

      assert redirected_to(conn) == ~p"/threads/#{thread.id}"
      assert get_flash(conn, :info) =~ "updated successfully"

      # Verify the update in the database
      updated_comment = Forum.get_comment!(comment.id)
      assert updated_comment.body == "Updated comment text"
    end

    test "moderator can update any comment", %{conn: conn, thread: thread, comment: comment} do
      moderator = moderator_fixture()

      conn =
        conn
        |> log_in_user(moderator)
        |> put(~p"/threads/#{thread.id}/comments/#{comment.id}", %{
          "comment" => %{"body" => "Moderator edited this"}
        })

      assert redirected_to(conn) == ~p"/threads/#{thread.id}"

      # Verify the update in the database
      updated_comment = Forum.get_comment!(comment.id)
      assert updated_comment.body == "Moderator edited this"
    end

    test "regular user cannot update another user's comment", %{conn: conn, thread: thread, comment: comment} do
      other_user = user_fixture()

      conn =
        conn
        |> log_in_user(other_user)
        |> put(~p"/threads/#{thread.id}/comments/#{comment.id}", %{
          "comment" => %{"body" => "Unauthorized edit attempt"}
        })

      assert redirected_to(conn) == ~p"/threads/#{thread.id}"
      assert get_flash(conn, :error) =~ "not authorized"

      # Verify no changes in the database
      unchanged_comment = Forum.get_comment!(comment.id)
      assert unchanged_comment.body == "Original comment"
    end
  end

  describe "delete comment" do
    setup [:create_test_data]

    test "user can delete their own comment", %{conn: conn, user: user, thread: thread, comment: comment} do
      conn =
        conn
        |> log_in_user(user)
        |> delete(~p"/threads/#{thread.id}/comments/#{comment.id}")

      assert redirected_to(conn) == ~p"/threads/#{thread.id}"
      assert get_flash(conn, :info) =~ "deleted successfully"

      # Verify deletion
      assert_raise Ecto.NoResultsError, fn ->
        Forum.get_comment!(comment.id)
      end
    end

    test "moderator can delete any comment", %{conn: conn, thread: thread, comment: comment} do
      moderator = moderator_fixture()

      conn =
        conn
        |> log_in_user(moderator)
        |> delete(~p"/threads/#{thread.id}/comments/#{comment.id}")

      assert redirected_to(conn) == ~p"/threads/#{thread.id}"

      # Verify deletion
      assert_raise Ecto.NoResultsError, fn ->
        Forum.get_comment!(comment.id)
      end
    end

    test "regular user cannot delete another user's comment", %{conn: conn, thread: thread, comment: comment} do
      other_user = user_fixture()

      conn =
        conn
        |> log_in_user(other_user)
        |> delete(~p"/threads/#{thread.id}/comments/#{comment.id}")

      assert redirected_to(conn) == ~p"/threads/#{thread.id}"
      assert get_flash(conn, :error) =~ "not authorized"

      # Verify comment still exists
      still_exists = Forum.get_comment!(comment.id)
      assert still_exists.id == comment.id
    end
  end
end
