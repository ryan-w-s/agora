defmodule Mix.Tasks.Agora.SetModeratorTest do
  use Agora.DataCase

  import Agora.AccountsFixtures
  alias Mix.Tasks.Agora.SetModerator
  alias Agora.Accounts

  test "sets a user as moderator by username" do
    user = user_fixture(%{username: "moduser", email: "moduser@example.com"})
    refute user.is_moderator

    # Run the task
    SetModerator.run([user.username, "true"])

    # Verify the change
    updated_user = Accounts.get_user_by_identifier(user.username)
    assert updated_user.is_moderator
  end

  test "sets a user as moderator by email" do
    user = user_fixture(%{username: "emailmod", email: "emailmod@example.com"})
    refute user.is_moderator

    # Run the task with email
    SetModerator.run([user.email, "true"])

    # Verify the change
    updated_user = Accounts.get_user!(user.id)
    assert updated_user.is_moderator
  end

  test "removes moderator status from a user" do
    user = user_fixture(%{username: "demoteuser", email: "demoteuser@example.com"})
    # First make them a moderator
    {:ok, user} =
      user
      |> Accounts.User.moderator_status_changeset(%{is_moderator: true})
      |> Agora.Repo.update()

    assert user.is_moderator

    # Run the task to demote
    SetModerator.run([user.username, "false"])

    # Verify the change
    updated_user = Accounts.get_user!(user.id)
    refute updated_user.is_moderator
  end

  test "fails with invalid status argument" do
    user = user_fixture()

    # Stub IO.puts to prevent prints in test output
    ExUnit.CaptureIO.capture_io(fn ->
      # We expect the process to exit, so we need to catch the exit
      catch_exit(SetModerator.run([user.username, "invalid"]))
    end)
  end

  test "fails with invalid user identifier" do
    # Stub IO.puts to prevent prints in test output
    ExUnit.CaptureIO.capture_io(fn ->
      # We expect the process to exit, so we need to catch the exit
      catch_exit(SetModerator.run(["nonexistent_user", "true"]))
    end)
  end

  test "fails with missing arguments" do
    # Stub IO.puts to prevent prints in test output
    ExUnit.CaptureIO.capture_io(fn ->
      # We expect the process to exit, so we need to catch the exit
      catch_exit(SetModerator.run([]))
    end)
  end
end
