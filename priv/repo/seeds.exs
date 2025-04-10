# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Agora.Repo.insert!(%Agora.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

register_or_get_user = fn attrs ->
  email = attrs[:email]

  case Agora.Accounts.get_user_by_email(email) do
    nil ->
      {:ok, user} = Agora.Accounts.register_user(attrs)
      IO.puts("Created user: #{user.username}")
      user

    user ->
      IO.puts("User already exists: #{user.username}")
      user
  end
end

password = "password1234"

register_or_get_user.(%{
  email: "alice@example.com",
  username: "alice",
  password: password
})

register_or_get_user.(%{
  email: "bob@example.com",
  username: "bob",
  password: password
})

register_or_get_user.(%{
  email: "charlie@example.com",
  username: "charlie",
  password: password
})
