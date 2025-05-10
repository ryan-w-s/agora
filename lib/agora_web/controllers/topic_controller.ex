defmodule AgoraWeb.TopicController do
  use AgoraWeb, :controller

  alias Agora.Forum
  alias Agora.Forum.Topic

  action_fallback AgoraWeb.FallbackController

  # --- Authorization Helper ---
  defp authorize_moderator(conn) do
    current_user = conn.assigns.current_user

    cond do
      is_nil(current_user) ->
        conn
        |> put_flash(:error, "You must be logged in to perform this action.")
        |> redirect(to: ~p"/users/log_in")
        |> halt()

      not current_user.is_moderator ->
        conn
        |> put_flash(:error, "You are not authorized to perform this action.")
        # Or perhaps to home page or the specific topic page
        |> redirect(to: ~p"/topics")
        |> halt()

        {:error, :unauthorized_not_moderator}

      true ->
        {:ok, conn}
    end
  end

  # --- Controller Actions ---
  def index(conn, _params) do
    topics = Forum.list_topics()
    render(conn, :index, topics: topics)
  end

  def new(conn, _params) do
    with {:ok, conn} <- authorize_moderator(conn) do
      changeset = Forum.change_topic(%Topic{})
      topics = Forum.list_topics()
      render(conn, :new, changeset: changeset, topics: topics)
    end
  end

  def create(conn, %{"topic" => topic_params}) do
    with {:ok, conn} <- authorize_moderator(conn) do
      case Forum.create_topic(topic_params) do
        {:ok, topic} ->
          conn
          |> put_flash(:info, "Topic created successfully.")
          |> redirect(to: ~p"/topics/#{topic}")

        {:error, %Ecto.Changeset{} = changeset} ->
          topics = Forum.list_topics()
          render(conn, :new, changeset: changeset, topics: topics)
      end
    end
  end

  def show(conn, %{"id" => id}) do
    topic = Forum.get_topic!(id)
    render(conn, :show, topic: topic)
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, conn} <- authorize_moderator(conn) do
      topic = Forum.get_topic!(id)
      changeset = Forum.change_topic(topic)
      topics = Forum.list_topics()
      render(conn, :edit, topic: topic, changeset: changeset, topics: topics)
    end
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    with {:ok, conn} <- authorize_moderator(conn) do
      topic = Forum.get_topic!(id)

      case Forum.update_topic(topic, topic_params) do
        {:ok, topic} ->
          conn
          |> put_flash(:info, "Topic updated successfully.")
          |> redirect(to: ~p"/topics/#{topic}")

        {:error, %Ecto.Changeset{} = changeset} ->
          topics = Forum.list_topics()
          render(conn, :edit, topic: topic, changeset: changeset, topics: topics)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, conn} <- authorize_moderator(conn) do
      topic = Forum.get_topic!(id)
      {:ok, _topic} = Forum.delete_topic(topic)

      conn
      |> put_flash(:info, "Topic deleted successfully.")
      |> redirect(to: ~p"/topics")
    end
  end
end
