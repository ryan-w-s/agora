defmodule Mix.Tasks.Agora.SetModerator do
  use Mix.Task

  @shortdoc "Sets a user's moderator status."
  @moduledoc """
  Sets the `is_moderator` field for a given user.

  This task requires the application to be started to access the database.

  ## Examples

      mix agora.set_moderator <username_or_email> <true|false>
      mix agora.set_moderator user@example.com true
      mix agora.set_moderator someuser false
  """

  alias Agora.Accounts
  alias Agora.Repo

  @impl Mix.Task
  def run([identifier, status_str]) do
    # Ensure the application is started
    Mix.Task.run("app.start")

    case String.downcase(status_str) do
      "true" ->
        set_moderator_status(identifier, true)

      "false" ->
        set_moderator_status(identifier, false)

      _ ->
        Mix.shell().error("Invalid status: '#{status_str}'. Must be 'true' or 'false'.")
        exit({:shutdown, 1})
    end
  end

  def run(_) do
    Mix.shell().error(
      "Invalid arguments. Usage: mix agora.set_moderator <username_or_email> <true|false>"
    )

    exit({:shutdown, 1})
  end

  defp set_moderator_status(identifier, new_status) do
    case Accounts.get_user_by_identifier(identifier) do
      nil ->
        Mix.shell().error("User not found: #{identifier}")
        exit({:shutdown, 1})

      user ->
        changeset = Accounts.User.moderator_status_changeset(user, %{is_moderator: new_status})

        case Repo.update(changeset) do
          {:ok, updated_user} ->
            Mix.shell().info(
              "Successfully updated moderator status for #{updated_user.username} to #{updated_user.is_moderator}."
            )

          {:error, failed_changeset} ->
            Mix.shell().error("Failed to update user: #{inspect(failed_changeset.errors)}")
            exit({:shutdown, 1})
        end
    end
  end
end
