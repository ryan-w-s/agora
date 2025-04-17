defmodule AgoraWeb.ThreadController do
  use AgoraWeb, :controller

  alias Agora.Forum
  alias Agora.Forum.Thread

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
    render(conn, :show, thread: thread)
  end

  def edit(conn, %{"id" => id}) do
    thread = Forum.get_thread!(id)
    changeset = Forum.change_thread(thread)
    topics = Forum.list_topics()
    render(conn, :edit, thread: thread, changeset: changeset, topics: topics)
  end

  def update(conn, %{"id" => id, "thread" => thread_params}) do
    thread = Forum.get_thread!(id)

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

  def delete(conn, %{"id" => id}) do
    thread = Forum.get_thread!(id)
    {:ok, _thread} = Forum.delete_thread(thread)

    conn
    |> put_flash(:info, "Thread deleted successfully.")
    |> redirect(to: ~p"/threads")
  end
end
