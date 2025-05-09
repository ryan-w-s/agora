defmodule AgoraWeb.ThreadController do
  use AgoraWeb, :controller

  alias Agora.Forum
  alias Agora.Forum.Thread
  alias Agora.Forum.Comment

  def index(conn, _params) do
    threads = Forum.list_threads()
    render(conn, :index, threads: threads)
  end

  def new(conn, %{"topic_id" => topic_id_str} = _params) do
    # Parse topic_id to integer
    topic_id = String.to_integer(topic_id_str)
    changeset = Forum.change_thread(%Thread{topic_id: topic_id})
    topics = Forum.list_topics()
    render(conn, :new, changeset: changeset, topic_id: topic_id, topics: topics)
  end

  def new(conn, _params) do
    changeset = Forum.change_thread(%Thread{})
    topics = Forum.list_topics()
    render(conn, :new, changeset: changeset, topic_id: nil, topics: topics)
  end

  def create(conn, %{"thread" => thread_params}) do
    # Assign the current user's ID to the thread parameters
    thread_params = Map.put(thread_params, "user_id", conn.assigns.current_user.id)

    case Forum.create_thread(thread_params) do
      {:ok, thread} ->
        conn
        |> put_flash(:info, "Thread created successfully.")
        |> redirect(to: ~p"/threads/#{thread}")

      {:error, %Ecto.Changeset{} = changeset} ->
        # Fetch topics again for re-rendering the form on error
        topics = Forum.list_topics()
        # Extract topic_id from params if available to keep it selected
        # Also parse to integer here for consistency when re-rendering
        topic_id =
          case thread_params["topic_id"] do
            nil -> nil
            id_str when is_binary(id_str) and id_str != "" -> String.to_integer(id_str)
            # Handle potential invalid values
            _ -> nil
          end

        render(conn, :new, changeset: changeset, topic_id: topic_id, topics: topics)
    end
  end

  def show(conn, %{"id" => id}) do
    thread = Forum.get_thread!(id)
    # Fetch comments for the thread
    comments = Forum.list_comments_for_thread(thread.id)
    # Prepare an empty changeset for the new comment form
    comment_changeset = Forum.change_comment(%Comment{})

    render(conn, :show,
      thread: thread,
      comments: comments,
      comment_changeset: comment_changeset
    )
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, thread} <- authorize_user_owns_thread(conn, id) do
      changeset = Forum.change_thread(thread)
      topics = Forum.list_topics()
      render(conn, :edit, thread: thread, changeset: changeset, topics: topics)
    end
  end

  def update(conn, %{"id" => id, "thread" => thread_params}) do
    with {:ok, thread} <- authorize_user_owns_thread(conn, id) do
      case Forum.update_thread(thread, thread_params) do
        {:ok, thread} ->
          conn
          |> put_flash(:info, "Thread updated successfully.")
          |> redirect(to: ~p"/threads/#{thread}")

        {:error, %Ecto.Changeset{} = changeset} ->
          # Fetch topics again for re-rendering the form on error
          topics = Forum.list_topics()
          render(conn, :edit, thread: thread, changeset: changeset, topics: topics)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, thread} <- authorize_user_owns_thread(conn, id) do
      # The thread variable from the with statement already has topic_id loaded
      # because authorize_user_owns_thread calls Forum.get_thread! which should preload it
      # or have it available. We can directly use thread.topic_id here.
      original_topic_id = thread.topic_id
      {:ok, _deleted_thread} = Forum.delete_thread(thread)

      conn
      |> put_flash(:info, "Thread deleted successfully.")
      |> redirect(to: ~p"/topics/#{original_topic_id}")
    end
  end

  # Add this private helper function at the end of the module
  defp authorize_user_owns_thread(conn, thread_id) do
    current_user = conn.assigns.current_user

    if is_nil(current_user) do
      conn
      |> put_flash(:error, "You must be logged in to perform this action.")
      |> redirect(to: ~p"/users/log_in")
      |> halt()

      {:error, :unauthorized}
    else
      thread = Forum.get_thread!(thread_id)

      if thread.user_id == current_user.id or current_user.is_moderator do
        {:ok, thread}
      else
        conn
        |> put_flash(:error, "You are not authorized to perform this action.")
        # Redirect to threads index on failure
        |> redirect(to: ~p"/threads")
        |> halt()

        {:error, :unauthorized}
      end
    end
  end
end
