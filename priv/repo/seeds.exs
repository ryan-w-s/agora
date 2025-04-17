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

IO.puts("\\nSeeding topics...")

# Parent topics
topics_to_insert = [
  %{name: "General Discussion", description: "Talk about anything."},
  %{name: "Technology", description: "Discussions about tech, software, and hardware."},
  %{name: "Off-Topic", description: "For everything else."}
]

# Use Enum.reduce to handle finding the technology topic ID and counting inserts
initial_acc = %{technology_topic_id: nil, inserted_count: 0}

acc = Enum.reduce(topics_to_insert, initial_acc, fn topic_attrs, acc ->
  current_topic_id =
    case Agora.Forum.get_topic_by_name(topic_attrs.name) do
      nil ->
        changeset = Agora.Forum.Topic.changeset(%Agora.Forum.Topic{}, topic_attrs)
        case Agora.Repo.insert(changeset) do
          {:ok, topic} ->
            IO.puts("Inserted parent topic: #{topic.name}")
            topic.id # Return the new topic's ID
          {:error, changeset} ->
            IO.inspect(changeset, label: "Error inserting parent topic #{topic_attrs.name}")
            nil # Return nil on error
        end
      existing_topic ->
         IO.puts("Parent topic already exists: #{existing_topic.name}")
         existing_topic.id # Return the existing topic's ID
    end

  # Update accumulator
  new_inserted_count = if is_nil(Agora.Forum.get_topic_by_name(topic_attrs.name)), do: acc.inserted_count + 1, else: acc.inserted_count
  new_tech_id = if topic_attrs.name == "Technology" and !is_nil(current_topic_id), do: current_topic_id, else: acc.technology_topic_id

  %{acc | technology_topic_id: new_tech_id, inserted_count: new_inserted_count}
end)

IO.puts("Finished processing parent topics. Newly inserted: #{acc.inserted_count}")

technology_topic_id = acc.technology_topic_id

# Child topic (nested under Technology)
if technology_topic_id do
  child_topic_attrs = %{
    name: "Programming",
    description: "Code, languages, frameworks, and more.",
    parent_topic_id: technology_topic_id
  }

  case Agora.Forum.get_topic_by_name(child_topic_attrs.name) do
    nil ->
      changeset = Agora.Forum.Topic.changeset(%Agora.Forum.Topic{}, child_topic_attrs)
      case Agora.Repo.insert(changeset) do
        {:ok, topic} ->
          IO.puts("Inserted child topic: #{topic.name}")
        {:error, changeset} ->
          IO.inspect(changeset, label: "Error inserting child topic #{child_topic_attrs.name}")
      end
    existing_topic ->
      IO.puts("Child topic already exists: #{existing_topic.name}")
  end

else
  IO.puts("Could not find 'Technology' topic to nest under. Skipping child topic insertion.")
end

IO.puts("Topic seeding finished.")
