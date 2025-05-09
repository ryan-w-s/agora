defmodule AgoraWeb.FallbackController do
  use AgoraWeb, :controller

  @doc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  def call(conn, {:error, :unauthorized_not_logged_in}) do
    conn
    |> put_status(:forbidden)
    |> put_flash(
      :error,
      conn.assigns.flash[:error] || "You must be logged in to access this page."
    )
    |> redirect(to: ~p"/users/log_in")
    |> halt()
  end

  def call(conn, {:error, :unauthorized_not_moderator}) do
    conn
    |> put_status(:forbidden)
    |> put_flash(
      :error,
      conn.assigns.flash[:error] || "You are not authorized to perform this action."
    )
    # Default redirect to home
    |> redirect(to: conn.assigns.flash[:redirect_to] || ~p"/")
    |> halt()
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> put_flash(
      :error,
      conn.assigns.flash[:error] || "You are not authorized to access this page."
    )
    |> redirect(to: conn.assigns.flash[:redirect_to] || ~p"/")
    |> halt()
  end

  # Fallback for other {:error, reason} tuples if necessary
  def call(conn, {:error, reason}) when is_atom(reason) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_flash(
      :error,
      "There was an issue: #{Atom.to_string(reason) |> String.replace("_", " ") |> String.capitalize()}"
    )
    |> redirect(
      to: conn.assigns.flash[:redirect_to] || Phoenix.Controller.current_path(conn) || ~p"/"
    )
    |> halt()
  end

  # Generic fallback for unhandled cases
  def call(conn, _reason) do
    conn
    |> put_status(:internal_server_error)
    |> put_flash(:error, "An unexpected error occurred.")
    |> redirect(to: ~p"/")
    |> halt()
  end
end
