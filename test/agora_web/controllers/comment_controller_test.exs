defmodule AgoraWeb.CommentControllerTest do
  use AgoraWeb.ConnCase

  import Agora.ForumFixtures
  alias Agora.Forum

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
end
