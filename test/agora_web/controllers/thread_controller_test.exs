defmodule AgoraWeb.ThreadControllerTest do
  use AgoraWeb.ConnCase

  import Agora.ForumFixtures

  defp log_in_user(context) do
    register_and_log_in_user(context)
  end

  defp create_topic(_) do
    topic = topic_fixture()
    %{topic: topic}
  end

  setup [:log_in_user, :create_topic]

  @create_attrs %{title: "some title", body: "some body"}
  @update_attrs %{title: "some updated title", body: "some updated body"}
  @invalid_attrs %{title: nil, body: nil}

  describe "index" do
    test "lists all threads", %{conn: conn} do
      conn = get(conn, ~p"/threads")
      assert html_response(conn, 200) =~ "Listing Threads"
    end
  end

  describe "new thread" do
    setup [:log_in_user]

    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/threads/new")
      assert html_response(conn, 200) =~ "New Thread"
    end

    test "renders form with topic_id", %{conn: conn, topic: topic} do
      conn = get(conn, ~p"/threads/new?topic_id=#{topic.id}")
      assert html_response(conn, 200) =~ "New Thread"
      assert conn.resp_body =~ "option selected value=\"#{topic.id}\""
    end
  end

  describe "create thread" do
    test "redirects to show when data is valid", %{conn: conn, topic: topic} do
      conn = post(conn, ~p"/threads", thread: Map.put(@create_attrs, :topic_id, topic.id))

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/threads/#{id}"

      conn = get(conn, ~p"/threads/#{id}")
      assert html_response(conn, 200) =~ @create_attrs.title
      assert html_response(conn, 200) =~ conn.assigns.current_user.username
    end

    test "renders errors when data is invalid", %{conn: conn, topic: topic} do
      conn = post(conn, ~p"/threads", thread: Map.put(@invalid_attrs, :topic_id, topic.id))
      assert html_response(conn, 200) =~ "New Thread"
    end
  end

  describe "edit thread" do
    setup [:create_thread]

    test "renders form for editing chosen thread", %{conn: conn, thread: thread} do
      conn = get(conn, ~p"/threads/#{thread}/edit")
      assert html_response(conn, 200) =~ "Edit Thread"
    end
  end

  describe "update thread" do
    setup [:create_thread]

    test "redirects when data is valid", %{conn: conn, thread: thread, topic: topic} do
      conn =
        put(conn, ~p"/threads/#{thread}", thread: Map.put(@update_attrs, :topic_id, topic.id))

      assert redirected_to(conn) == ~p"/threads/#{thread}"

      conn = get(conn, ~p"/threads/#{thread}")
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, thread: thread, topic: topic} do
      conn =
        put(conn, ~p"/threads/#{thread}", thread: Map.put(@invalid_attrs, :topic_id, topic.id))

      assert html_response(conn, 200) =~ "Edit Thread"
    end
  end

  describe "delete thread" do
    setup [:create_thread]

    test "deletes chosen thread", %{conn: conn, thread: thread} do
      conn = delete(conn, ~p"/threads/#{thread}")
      assert redirected_to(conn) == ~p"/topics/#{thread.topic_id}"

      assert_error_sent 404, fn ->
        get(conn, ~p"/threads/#{thread}")
      end
    end
  end

  defp create_thread(%{user: user, topic: topic}) do
    thread = thread_fixture(%{user_id: user.id, topic_id: topic.id})
    %{thread: thread}
  end
end
