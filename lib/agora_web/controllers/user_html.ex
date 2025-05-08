defmodule AgoraWeb.UserHTML do
  use AgoraWeb, :html

  embed_templates "user_html/*"

  # If we had a user_form component, its attributes would be defined here.
  # For now, this module primarily serves to enable rendering of user_html templates.
end
