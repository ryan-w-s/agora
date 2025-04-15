defmodule AgoraWeb.UserRegistrationControllerTest do
  use AgoraWeb.ConnCase

  import Agora.AccountsFixtures

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, ~p"/users/register")
      response = html_response(conn, 200)
      assert response =~ "Register"
      assert response =~ ~p"/users/log_in"
      assert response =~ ~p"/users/register"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> get(~p"/users/register")

      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "POST /users/register creates account and logs the user in", %{conn: conn} do
      email = unique_user_email()
      # Simple unique username
      username = "user_#{String.slice(email, 5..10)}"
      password = valid_user_password()

      conn =
        post(conn, ~p"/users/register", %{
          "user" => %{
            "email" => email,
            "username" => username,
            "password" => password,
            "password_confirmation" => password
          }
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/"

      # The session ramps up complexity significantly compared to the request,
      # so we don't assert on the HTML response.
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"/users/register", %{
          "user" => %{
            "email" => "with spaces",
            "password" => "too short",
            "username" => ""
          }
        })

      response = html_response(conn, 200)
      assert response =~ "Register"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
      assert response =~ "can&#39;t be blank"
    end
  end
end
