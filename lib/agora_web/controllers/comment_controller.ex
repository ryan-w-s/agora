defmodule AgoraWeb.CommentController do
  use AgoraWeb, :controller

  alias Agora.Forum
  # alias Agora.Forum.Comment # Removed unused alias

  def create(conn, %{"thread_id" => thread_id, "comment" => comment_params}) do
    user = conn.assigns.current_user

    # Add user_id and thread_id to the comment parameters
    comment_params = Map.put(comment_params, "user_id", user.id)
    comment_params = Map.put(comment_params, "thread_id", thread_id)

    case Forum.create_comment(comment_params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment posted successfully.")
        |> redirect(to: ~p"/threads/#{thread_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        # If there's an error, redirect back to the thread page.
        # We'll display the error using flash messages.
        # We need to pass the changeset errors back somehow, maybe via flash?
        # For now, just redirecting with a generic error flash.
        conn
        |> put_flash(:error, "Could not post comment. #{inspect(changeset.errors)}")
        |> redirect(to: ~p"/threads/#{thread_id}")
    end
  end
end
