defmodule AgoraWeb.PageController do
  use AgoraWeb, :controller

  alias Agora.Forum

  def home(conn, _params) do
    # Fetch only top-level topics
    topics = Forum.list_top_level_topics()
    # Render with the default app layout
    render(conn, :home, topics: topics)
  end
end
