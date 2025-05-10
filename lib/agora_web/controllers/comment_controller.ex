# credo:disable-for-this-file Credo.Check.Refactor.Nesting
# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity

defmodule AgoraWeb.CommentController do
  use AgoraWeb, :controller

  alias Agora.Forum
  # alias Agora.Forum.Comment

  def create(conn, %{"thread_id" => _thread_id, "comment" => comment_params}) do
    # Only logged-in users may post comments
    current_user = conn.assigns.current_user

    if is_nil(current_user) do
      conn
      |> put_flash(:error, "You must be logged in to post a comment.")
      |> redirect(to: ~p"/users/log_in")
      |> halt()
    else
      user = current_user

      # Add user_id and thread_id to the comment parameters
      # The thread_id from params is still used here to associate the comment
      # Keep original for association if needed
      original_thread_id = conn.params["thread_id"]
      comment_params = Map.put(comment_params, "user_id", user.id)
      comment_params = Map.put(comment_params, "thread_id", original_thread_id)

      case Forum.create_comment(comment_params) do
        {:ok, comment} ->
          conn
          |> put_flash(:info, "Comment posted successfully.")
          # Use comment.thread_id from the created record
          |> redirect(to: ~p"/threads/#{comment.thread_id}")

        {:error, %Ecto.Changeset{} = changeset} ->
          # If there's an error, redirect back to the thread page.
          # We'll display the error using flash messages.
          thread_id_for_redirect =
            case comment_params["thread_id"] do
              nil ->
                conn.params["thread_id"]

              id ->
                id
            end

          conn
          |> put_flash(:error, "Could not post comment. #{inspect(changeset.errors)}")
          |> redirect(to: ~p"/threads/#{thread_id_for_redirect}")
      end
    end
  end

  def edit(conn, %{"thread_id" => thread_id, "id" => id}) do
    # Ensure thread_id is an integer if it comes as a string
    thread_id_int = String.to_integer(thread_id)

    with {:ok, comment} <- authorize_user_owns_comment_or_is_moderator(conn, id) do
      changeset = Forum.change_comment(comment)
      # Pass thread_id to the template, ensuring it's the integer version
      render(conn, :edit, comment: comment, changeset: changeset, thread_id: thread_id_int)
    end
  end

  def update(conn, %{"thread_id" => thread_id, "id" => id, "comment" => comment_params}) do
    # Ensure thread_id is an integer
    thread_id_int = String.to_integer(thread_id)

    with {:ok, comment} <- authorize_user_owns_comment_or_is_moderator(conn, id) do
      case Forum.update_comment(comment, comment_params) do
        {:ok, updated_comment} ->
          conn
          |> put_flash(:info, "Comment updated successfully.")
          # Use updated_comment.thread_id
          |> redirect(to: ~p"/threads/#{updated_comment.thread_id}")

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, :edit,
            comment: comment,
            changeset: changeset,
            # Pass integer thread_id
            thread_id: thread_id_int
          )
      end
    end
  end

  def delete(conn, %{"thread_id" => thread_id, "id" => id}) do
    # Ensure thread_id is an integer
    thread_id_int = String.to_integer(thread_id)

    with {:ok, comment} <- authorize_user_owns_comment_or_is_moderator(conn, id) do
      {:ok, _deleted_comment} = Forum.delete_comment(comment)

      conn
      |> put_flash(:info, "Comment deleted successfully.")
      # Use integer thread_id for redirect
      |> redirect(to: ~p"/threads/#{thread_id_int}")
    end
  end

  defp authorize_user_owns_comment_or_is_moderator(conn, comment_id) do
    # Only logged-in users may edit or delete comments
    current_user = conn.assigns.current_user

    if is_nil(current_user) do
      # Redirect to login if anonymous
      conn
      |> put_flash(:error, "You must be logged in to perform this action.")
      |> redirect(to: ~p"/users/log_in")
      |> halt()
    else
      # Preload thread
      comment = Forum.get_comment!(comment_id) |> Agora.Repo.preload(:thread)

      # Ensure comment and its thread exist, and user is author or moderator
      if !is_nil(comment) && !is_nil(comment.thread) &&
           (comment.user_id == current_user.id || current_user.is_moderator) do
        {:ok, comment}
      else
        # Attempt to get thread_id for redirect, fallback to a default if not available
        thread_id_for_redirect =
          cond do
            !is_nil(comment) && !is_nil(comment.thread) -> comment.thread.id
            !is_nil(conn.params["thread_id"]) -> conn.params["thread_id"]
            true -> ""
          end

        # Redirect and halt, then return conn
        conn
        |> put_flash(:error, "You are not authorized to perform this action.")
        |> redirect(to: ~p"/threads/#{thread_id_for_redirect}")
        |> halt()
      end
    end
  end
end
