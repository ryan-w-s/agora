defmodule AgoraWeb.ThreadControllerTest do
  use AgoraWeb.ConnCase

  import Agora.ForumFixtures

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
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/threads/new")
      assert html_response(conn, 200) =~ "New Thread"
    end
  end

  describe "create thread" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/threads", thread: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/threads/#{id}"

      conn = get(conn, ~p"/threads/#{id}")
      assert html_response(conn, 200) =~ "Thread #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/threads", thread: @invalid_attrs)
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

    test "redirects when data is valid", %{conn: conn, thread: thread} do
      conn = put(conn, ~p"/threads/#{thread}", thread: @update_attrs)
      assert redirected_to(conn) == ~p"/threads/#{thread}"

      conn = get(conn, ~p"/threads/#{thread}")
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, thread: thread} do
      conn = put(conn, ~p"/threads/#{thread}", thread: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Thread"
    end
  end

  describe "delete thread" do
    setup [:create_thread]

    test "deletes chosen thread", %{conn: conn, thread: thread} do
      conn = delete(conn, ~p"/threads/#{thread}")
      assert redirected_to(conn) == ~p"/threads"

      assert_error_sent 404, fn ->
        get(conn, ~p"/threads/#{thread}")
      end
    end
  end

  defp create_thread(_) do
    thread = thread_fixture()
    %{thread: thread}
  end
end
