defmodule Mix.Tasks.Agora.SetModeratorTest do
  use Agora.DataCase

  import Agora.AccountsFixtures
  alias Mix.Tasks.Agora.SetModerator
  alias Agora.Accounts

  test "sets a user as moderator by username" do
    user = user_fixture(%{username: "moduser", email: "moduser@example.com"})
    refute user.is_moderator

    ExUnit.CaptureIO.capture_io(fn ->
      SetModerator.run([user.username, "true"])
    end)

    updated_user = Accounts.get_user_by_identifier(user.username)
    assert updated_user.is_moderator
  end

  test "sets a user as moderator by email" do
    user = user_fixture(%{username: "emailmod", email: "emailmod@example.com"})
    refute user.is_moderator

    ExUnit.CaptureIO.capture_io(fn ->
      SetModerator.run([user.email, "true"])
    end)

    updated_user = Accounts.get_user!(user.id)
    assert updated_user.is_moderator
  end

  test "removes moderator status from a user" do
    user = user_fixture(%{username: "demoteuser", email: "demoteuser@example.com"})
    {:ok, user} =
      user
      |> Accounts.User.moderator_status_changeset(%{is_moderator: true})
      |> Agora.Repo.update()
    assert user.is_moderator

    ExUnit.CaptureIO.capture_io(fn ->
      SetModerator.run([user.username, "false"])
    end)

    updated_user = Accounts.get_user!(user.id)
    refute updated_user.is_moderator
  end

  test "fails with invalid status argument" do
    user = user_fixture()
    ExUnit.CaptureIO.capture_io(fn ->
      catch_exit(SetModerator.run([user.username, "invalid"]))
    end)
  end

  test "fails with invalid user identifier" do
    ExUnit.CaptureIO.capture_io(fn ->
      catch_exit(SetModerator.run(["nonexistent_user", "true"]))
    end)
  end

  test "fails with missing arguments" do
    ExUnit.CaptureIO.capture_io(fn ->
      catch_exit(SetModerator.run([]))
    end)
  end
end
