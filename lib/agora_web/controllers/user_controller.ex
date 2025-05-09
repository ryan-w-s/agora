# credo:disable-for-this-file Credo.Check.Refactor.Nesting
defmodule AgoraWeb.UserController do
  use AgoraWeb, :controller

  alias Agora.Accounts

  def show(conn, %{"username_identifier" => username_identifier}) do
    # IO.inspect(username_identifier, label: "UserController.show received username_identifier:") # Removed logging
    case Accounts.get_user_by_identifier(username_identifier) do
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
  def set_moderator_status(conn, %{
        "username_identifier" => username_to_change_status_for,
        "status" => status_str
      }) do
    current_user = conn.assigns.current_user

    if current_user && current_user.is_moderator do
      target_user = Accounts.get_user_by_identifier(username_to_change_status_for)

      cond do
        is_nil(target_user) ->
          conn
          |> put_flash(:error, "Target user not found.")
          |> redirect(to: ~p"/")
          |> halt()

        current_user.id == target_user.id ->
          conn
          |> put_flash(:error, "You cannot change your own moderator status here.")
          |> redirect(to: ~p"/users/#{target_user.username}")
          |> halt()

        true ->
          new_status = status_str == "true"

          changeset =
            Accounts.User.moderator_status_changeset(target_user, %{is_moderator: new_status})

          case Agora.Repo.update(changeset) do
            {:ok, updated_user} ->
              action_verb = if updated_user.is_moderator, do: "promoted", else: "demoted"

              conn
              |> put_flash(:info, "User #{updated_user.username} has been #{action_verb}.")
              |> redirect(to: ~p"/users/#{updated_user.username}")

            {:error, _failed_changeset} ->
              conn
              |> put_flash(:error, "Failed to update moderator status.")
              |> redirect(to: ~p"/users/#{target_user.username}")
          end
      end
    else
      conn
      |> put_flash(:error, "You are not authorized to perform this action.")
      |> redirect(to: ~p"/users/#{username_to_change_status_for}")
      |> halt()
    end
  end
end
