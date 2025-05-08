defmodule AgoraWeb.CommentHTML do
  use AgoraWeb, :html

  embed_templates "comment_html/*"

  @doc """
  Renders a comment form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  # thread_id is needed to construct the correct action URL for the form
  attr :thread_id, :integer, required: true
  # Optional, used for edit form
  attr :comment, Agora.Forum.Comment, default: nil

  def comment_form(assigns)
end
