defmodule AgoraWeb.TopicControllerTest do
  use AgoraWeb.ConnCase

  alias Agora.Accounts
  alias Agora.Repo

  import Agora.AccountsFixtures
  import Agora.ForumFixtures

  # --- Test Setup Helpers for Moderator ---
  # Creates a user and explicitly updates it to be a moderator
  defp moderator_fixture(attrs \\ %{}) do
    user = user_fixture(attrs)

    {:ok, moderator} =
      user
      |> Accounts.User.moderator_status_changeset(%{is_moderator: true})
      |> Repo.update()

    moderator
  end

  # Logs in a moderator user
  defp log_in_moderator(%{conn: conn}) do
    moderator = moderator_fixture()
    conn = log_in_user(conn, moderator)
    %{conn: conn}
  end

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}

  describe "index" do
    test "lists all topics", %{conn: conn} do
      conn = get(conn, ~p"/topics")
      assert html_response(conn, 200) =~ "Listing Topics"
    end
  end

  describe "new topic" do
    setup [:log_in_moderator]

    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/topics/new")
      assert html_response(conn, 200) =~ "New Topic"
    end
  end

  describe "create topic" do
    setup [:log_in_moderator]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/topics", topic: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/topics/#{id}"

      conn = get(conn, ~p"/topics/#{id}")
      assert html_response(conn, 200) =~ @create_attrs.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/topics", topic: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Topic"
    end
  end

  describe "edit topic" do
    setup [:log_in_moderator, :create_topic]

    test "renders form for editing chosen topic", %{conn: conn, topic: topic} do
      conn = get(conn, ~p"/topics/#{topic}/edit")
      assert html_response(conn, 200) =~ "Edit Topic"
    end
  end

  describe "update topic" do
    setup [:log_in_moderator, :create_topic]

    test "redirects when data is valid", %{conn: conn, topic: topic} do
      conn = put(conn, ~p"/topics/#{topic}", topic: @update_attrs)
      assert redirected_to(conn) == ~p"/topics/#{topic}"

      conn = get(conn, ~p"/topics/#{topic}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, topic: topic} do
      conn = put(conn, ~p"/topics/#{topic}", topic: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Topic"
    end
  end

  describe "delete topic" do
    setup [:log_in_moderator, :create_topic]

    test "deletes chosen topic", %{conn: conn, topic: topic} do
      conn = delete(conn, ~p"/topics/#{topic}")
      assert redirected_to(conn) == ~p"/topics"

      assert_error_sent 404, fn ->
        get(conn, ~p"/topics/#{topic}")
      end
    end
  end

  # Creates a topic fixture for tests
  defp create_topic(%{conn: _conn}) do
    topic = topic_fixture()
    %{topic: topic}
  end
end
