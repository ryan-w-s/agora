defmodule AgoraWeb.TopicHTML do
  use AgoraWeb, :html

  embed_templates "topic_html/*"

  @doc """
  Renders a topic form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :topics, :list, required: true

  def topic_form(assigns)
end
