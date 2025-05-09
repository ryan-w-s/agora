defmodule AgoraWeb.UserControllerTest do
  use AgoraWeb.ConnCase

  alias Agora.Accounts
  alias Agora.Repo
  import Agora.AccountsFixtures

  # Creates a user and explicitly updates it to be a moderator
  defp moderator_fixture(attrs \\ %{}) do
    # First create a regular user
    user = user_fixture(attrs)

    # Then explicitly update to make them a moderator
    {:ok, moderator} =
      user
      |> Accounts.User.moderator_status_changeset(%{is_moderator: true})
      |> Repo.update()

    moderator
  end

  describe "GET /users/:username_identifier - User Profile" do
    test "can view a user profile by username" do
      user = user_fixture(%{username: "viewableuser", email: "viewable@example.com"})
      conn = build_conn() |> get(~p"/users/#{user.username}")

      assert html_response(conn, 200) =~ "Profile: #{user.username}"
      assert html_response(conn, 200) =~ user.email
    end

    test "redirects to home page when user not found" do
      conn = build_conn() |> get(~p"/users/nonexistentuser")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "User not found"
    end

    test "shows moderator status for moderator users" do
      moderator = moderator_fixture(%{username: "modstatususer"})
      conn = build_conn() |> get(~p"/users/#{moderator.username}")

      assert html_response(conn, 200) =~ "Moderator"
    end
  end

  describe "POST /users/:username_identifier/set_moderator_status" do
    test "moderator promotes a regular user" do
      moderator = moderator_fixture()
      regular_user = user_fixture(%{username: "regularjoe", email: "regularjoe@example.com"})

      conn =
        build_conn()
        |> log_in_user(moderator)
        |> post(~p"/users/#{regular_user.username}/set_moderator_status?status=true")

      assert redirected_to(conn) == ~p"/users/#{regular_user.username}"

      conn = get(conn, ~p"/users/#{regular_user.username}")
      assert html_response(conn, 200) =~ "User #{regular_user.username} has been promoted"

      assert Accounts.get_user_by_identifier(regular_user.username).is_moderator == true
    end

    test "moderator demotes another moderator" do
      moderator = moderator_fixture()
      other_moderator = moderator_fixture(%{username: "othermod", email: "othermod@example.com"})

      conn =
        build_conn()
        |> log_in_user(moderator)
        |> post(~p"/users/#{other_moderator.username}/set_moderator_status?status=false")

      assert redirected_to(conn) == ~p"/users/#{other_moderator.username}"

      conn = get(conn, ~p"/users/#{other_moderator.username}")
      assert html_response(conn, 200) =~ "User #{other_moderator.username} has been demoted"

      assert Accounts.get_user_by_identifier(other_moderator.username).is_moderator == false
    end

    test "non-moderator cannot change status" do
      non_moderator = user_fixture(%{username: "activeuser", email: "activeuser@example.com"})
      target_user = user_fixture(%{username: "targetuser", email: "targetuser@example.com"})

      conn =
        build_conn()
        |> log_in_user(non_moderator)
        |> post(~p"/users/#{target_user.username}/set_moderator_status?status=true")

      assert redirected_to(conn) == ~p"/users/#{target_user.username}"

      conn = get(conn, ~p"/users/#{target_user.username}")
      assert html_response(conn, 200) =~ "You are not authorized to perform this action"

      assert Accounts.get_user_by_identifier(target_user.username).is_moderator == false
    end

    test "user cannot change their own status" do
      moderator_user = moderator_fixture(%{username: "selfmod"})

      conn =
        build_conn()
        |> log_in_user(moderator_user)
        |> post(~p"/users/#{moderator_user.username}/set_moderator_status?status=false")

      assert redirected_to(conn) == ~p"/users/#{moderator_user.username}"

      conn = get(conn, ~p"/users/#{moderator_user.username}")
      assert html_response(conn, 200) =~ "You cannot change your own moderator status here"

      assert Accounts.get_user_by_identifier(moderator_user.username).is_moderator == true
    end

    test "attempting to change status of non-existent user" do
      moderator = moderator_fixture()

      conn =
        build_conn()
        |> log_in_user(moderator)
        |> post(~p"/users/nonexistentuser/set_moderator_status?status=true")

      assert redirected_to(conn) == ~p"/"

      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Target user not found"
    end
  end
end
