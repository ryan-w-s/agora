defmodule AgoraWeb.ThreadHTML do
  use AgoraWeb, :html

  embed_templates "thread_html/*"

  @doc """
  Renders a thread form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def thread_form(assigns)
end
