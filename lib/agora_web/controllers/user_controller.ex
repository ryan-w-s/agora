# credo:disable-for-this-file Credo.Check.Refactor.Nesting
defmodule AgoraWeb.UserController do
  use AgoraWeb, :controller

  alias Agora.Accounts

  def show(conn, %{"id" => id}) do
    # IO.inspect(id, label: "UserController.show received id:") # Removed logging
    case Accounts.get_user_by_identifier(id) do
      nil ->
        conn
        |> put_flash(:error, "User not found.")
        # Redirect to home or another appropriate page
        |> redirect(to: ~p"/")
        |> halt()

      user ->
        # Fetch recent activity (placeholder for now)
        recent_activity = []
        render(conn, :show, user: user, recent_activity: recent_activity)
    end
  end

  # Action for promoting/demoting a user
  # This will be a POST request
  def set_moderator_status(conn, %{"id" => user_id_to_change, "status" => status_str}) do
    current_user = conn.assigns.current_user

    # 1. Authorization: Only moderators can perform this action
    if !current_user || !current_user.is_moderator do
      conn
      |> put_flash(:error, "You are not authorized to perform this action.")
      # Redirect back to profile
      |> redirect(to: ~p"/users/#{user_id_to_change}")
      |> halt()
    else
      # 2. Prevent self-promotion/demotion via this specific UI action for safety
      # They can use the mix task for themselves if needed.
      # Ensure we get a user struct before trying to access .id
      target_user_for_self_check = Accounts.get_user_by_identifier(user_id_to_change)

      if !is_nil(target_user_for_self_check) && current_user.id == target_user_for_self_check.id do
        conn
        |> put_flash(:error, "You cannot change your own moderator status here.")
        |> redirect(to: ~p"/users/#{user_id_to_change}")
        |> halt()
      else
        # Re-fetch or use target_user_for_self_check if it's confirmed not nil
        # For safety, re-fetching here ensures we operate on a fresh state if needed,
        # though target_user_for_self_check could be used if it's not nil.
        target_user = Accounts.get_user_by_identifier(user_id_to_change)
        new_status = status_str == "true"

        if is_nil(target_user) do
          conn
          |> put_flash(:error, "Target user not found.")
          # Or some other appropriate redirect
          |> redirect(to: ~p"/")
          |> halt()
        else
          changeset =
            Accounts.User.moderator_status_changeset(target_user, %{is_moderator: new_status})

          case Agora.Repo.update(changeset) do
            {:ok, updated_user} ->
              action_verb = if updated_user.is_moderator, do: "promoted", else: "demoted"

              conn
              |> put_flash(:info, "User #{updated_user.username} has been #{action_verb}.")
              # Redirect to target user's profile by ID
              |> redirect(to: ~p"/users/#{updated_user.id}")

            {:error, _failed_changeset} ->
              conn
              |> put_flash(:error, "Failed to update moderator status.")
              # Redirect back to profile
              |> redirect(to: ~p"/users/#{user_id_to_change}")
          end
        end
      end
    end
  end
end
