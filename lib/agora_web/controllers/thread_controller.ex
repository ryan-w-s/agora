defmodule AgoraWeb.ThreadController do
  use AgoraWeb, :controller

  alias Agora.Forum
  alias Agora.Forum.Thread

  def index(conn, _params) do
    threads = Forum.list_threads()
    render(conn, :index, threads: threads)
  end

  def new(conn, _params) do
    changeset = Forum.change_thread(%Thread{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"thread" => thread_params}) do
    case Forum.create_thread(thread_params) do
      {:ok, thread} ->
        conn
        |> put_flash(:info, "Thread created successfully.")
        |> redirect(to: ~p"/threads/#{thread}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    thread = Forum.get_thread!(id)
    render(conn, :show, thread: thread)
  end

  def edit(conn, %{"id" => id}) do
    thread = Forum.get_thread!(id)
    changeset = Forum.change_thread(thread)
    render(conn, :edit, thread: thread, changeset: changeset)
  end

  def update(conn, %{"id" => id, "thread" => thread_params}) do
    thread = Forum.get_thread!(id)

    case Forum.update_thread(thread, thread_params) do
      {:ok, thread} ->
        conn
        |> put_flash(:info, "Thread updated successfully.")
        |> redirect(to: ~p"/threads/#{thread}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, thread: thread, changeset: changeset)
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
