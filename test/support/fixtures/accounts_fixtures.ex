defmodule Agora.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Agora.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  def unique_user_username,
    do: "user#{:crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)}"

  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      username: unique_user_username(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    case attrs
         |> valid_user_attributes()
         |> Agora.Accounts.register_user() do
      {:ok, user} ->
        user

      {:error, changeset} ->
        # Raise a more informative error if fixture creation fails
        raise "Failed to create user fixture. Errors: #{inspect(changeset.errors)}"
    end
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
