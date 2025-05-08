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

  describe "POST /users/:username_identifier/set_moderator_status - debugging" do
    test "debug moderator action" do
      # Create a moderator user
      moderator = moderator_fixture()
      IO.inspect(moderator, label: "MODERATOR USER")

      # Create a regular user to promote
      regular_user = user_fixture(%{username: "regularjoe", email: "regularjoe@example.com"})
      IO.inspect(regular_user, label: "REGULAR USER")

      # Authenticate as moderator
      conn = build_conn()
      conn = log_in_user(conn, moderator)

      # Verify that we're properly logged in
      session = Plug.Conn.get_session(conn)
      IO.inspect(session, label: "SESSION AFTER LOGIN")

      # Verify that auth token is valid by fetching user
      token = Plug.Conn.get_session(conn, :user_token)
      fetched_user = Agora.Accounts.get_user_by_session_token(token)
      IO.inspect(fetched_user, label: "USER FROM TOKEN")

      # Make the request
      conn = post(conn, ~p"/users/#{regular_user.username}/set_moderator_status?status=true")

      # Check if current_user is properly set in the controller
      IO.inspect(conn.assigns[:current_user], label: "CURRENT USER IN CONTROLLER")

      # Check redirect and flash
      redirect_path = redirected_to(conn)
      IO.inspect(redirect_path, label: "REDIRECT PATH")
      flash = conn.assigns.flash
      IO.inspect(flash, label: "FLASH MESSAGES")

      # Debug the response even if no redirect
      if is_nil(redirect_path) do
        IO.inspect(html_response(conn, 200), label: "HTML RESPONSE")
      end

      # Try to follow redirect and check content
      if redirect_path do
        next_conn = get(conn, redirect_path)
        flash_on_next_page = next_conn.assigns.flash
        IO.inspect(flash_on_next_page, label: "FLASH ON REDIRECT PAGE")
        response = html_response(next_conn, 200)
        IO.inspect(String.slice(response, 0, 500), label: "RESPONSE START")
      end
    end
  end

  describe "POST /users/:username_identifier/set_moderator_status" do
    test "moderator promotes a regular user" do
      moderator = moderator_fixture()
      regular_user = user_fixture(%{username: "regularjoe", email: "regularjoe@example.com"})

      # Authenticate as moderator and post the promotion request
      conn =
        build_conn()
        |> log_in_user(moderator)
        |> post(~p"/users/#{regular_user.username}/set_moderator_status?status=true")

      # Check the redirect location
      assert redirected_to(conn) == ~p"/users/#{regular_user.username}"

      # Follow the redirect to see the flash message
      conn = get(conn, ~p"/users/#{regular_user.username}")
      assert html_response(conn, 200) =~ "User #{regular_user.username} has been promoted"

      # Verify the database change
      assert Accounts.get_user_by_identifier(regular_user.username).is_moderator == true
    end

    test "moderator demotes another moderator" do
      moderator = moderator_fixture()
      other_moderator = moderator_fixture(%{username: "othermod", email: "othermod@example.com"})

      # Authenticate as moderator and post the demotion request
      conn =
        build_conn()
        |> log_in_user(moderator)
        |> post(~p"/users/#{other_moderator.username}/set_moderator_status?status=false")

      # Check the redirect location
      assert redirected_to(conn) == ~p"/users/#{other_moderator.username}"

      # Follow the redirect to see the flash message
      conn = get(conn, ~p"/users/#{other_moderator.username}")
      assert html_response(conn, 200) =~ "User #{other_moderator.username} has been demoted"

      # Verify the database change
      assert Accounts.get_user_by_identifier(other_moderator.username).is_moderator == false
    end

    test "non-moderator cannot change status" do
      non_moderator = user_fixture(%{username: "activeuser", email: "activeuser@example.com"})
      target_user = user_fixture(%{username: "targetuser", email: "targetuser@example.com"})

      # Authenticate as non-moderator and post the promotion request
      conn =
        build_conn()
        |> log_in_user(non_moderator)
        |> post(~p"/users/#{target_user.username}/set_moderator_status?status=true")

      # Check the redirect location
      assert redirected_to(conn) == ~p"/users/#{target_user.username}"

      # Follow the redirect to see the flash message
      conn = get(conn, ~p"/users/#{target_user.username}")
      assert html_response(conn, 200) =~ "You are not authorized to perform this action"

      # Verify no database change
      assert Accounts.get_user_by_identifier(target_user.username).is_moderator == false
    end

    test "user cannot change their own status" do
      moderator_user = moderator_fixture(%{username: "selfmod"})

      # Authenticate as moderator and try to change their own status
      conn =
        build_conn()
        |> log_in_user(moderator_user)
        |> post(~p"/users/#{moderator_user.username}/set_moderator_status?status=false")

      # Check the redirect location
      assert redirected_to(conn) == ~p"/users/#{moderator_user.username}"

      # Follow the redirect to see the flash message
      conn = get(conn, ~p"/users/#{moderator_user.username}")
      assert html_response(conn, 200) =~ "You cannot change your own moderator status here"

      # Verify no database change
      assert Accounts.get_user_by_identifier(moderator_user.username).is_moderator == true
    end

    test "attempting to change status of non-existent user" do
      moderator = moderator_fixture()

      # Authenticate as moderator and try to promote non-existent user
      conn =
        build_conn()
        |> log_in_user(moderator)
        |> post(~p"/users/nonexistentuser/set_moderator_status?status=true")

      # Check the redirect location
      assert redirected_to(conn) == ~p"/"

      # Follow the redirect to see the flash message
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Target user not found"
    end
  end
end
