defmodule AgoraWeb.TopicController do
  use AgoraWeb, :controller

  alias Agora.Forum
  alias Agora.Forum.Topic

  def index(conn, _params) do
    topics = Forum.list_topics()
    render(conn, :index, topics: topics)
  end

  def new(conn, _params) do
    changeset = Forum.change_topic(%Topic{})
    topics = Forum.list_topics()
    render(conn, :new, changeset: changeset, topics: topics)
  end

  def create(conn, %{"topic" => topic_params}) do
    case Forum.create_topic(topic_params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: ~p"/topics/#{topic}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    topic = Forum.get_topic!(id)
    render(conn, :show, topic: topic)
  end

  def edit(conn, %{"id" => id}) do
    topic = Forum.get_topic!(id)
    changeset = Forum.change_topic(topic)
    topics = Forum.list_topics()
    render(conn, :edit, topic: topic, changeset: changeset, topics: topics)
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Forum.get_topic!(id)

    case Forum.update_topic(topic, topic_params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: ~p"/topics/#{topic}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, topic: topic, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Forum.get_topic!(id)
    {:ok, _topic} = Forum.delete_topic(topic)

    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: ~p"/topics")
  end
end
