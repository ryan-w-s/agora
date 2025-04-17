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

acc =
  Enum.reduce(topics_to_insert, initial_acc, fn topic_attrs, acc ->
    current_topic_id =
      case Agora.Forum.get_topic_by_name(topic_attrs.name) do
        nil ->
          changeset = Agora.Forum.Topic.changeset(%Agora.Forum.Topic{}, topic_attrs)

          case Agora.Repo.insert(changeset) do
            {:ok, topic} ->
              IO.puts("Inserted parent topic: #{topic.name}")
              # Return the new topic's ID
              topic.id

            {:error, changeset} ->
              IO.inspect(changeset, label: "Error inserting parent topic #{topic_attrs.name}")
              # Return nil on error
              nil
          end

        existing_topic ->
          IO.puts("Parent topic already exists: #{existing_topic.name}")
          # Return the existing topic's ID
          existing_topic.id
      end

    # Update accumulator
    new_inserted_count =
      if is_nil(Agora.Forum.get_topic_by_name(topic_attrs.name)),
        do: acc.inserted_count + 1,
        else: acc.inserted_count

    new_tech_id =
      if topic_attrs.name == "Technology" and !is_nil(current_topic_id),
        do: current_topic_id,
        else: acc.technology_topic_id

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

IO.puts("Seeding threads...")

# Parent topic (General Discussion)
general_discussion_topic = Agora.Forum.get_topic_by_name("General Discussion")

general_discussion_topic_id =
  if general_discussion_topic do
    general_discussion_topic.id
  else
    IO.puts("Could not find 'General Discussion' topic. Skipping thread insertion.")
    nil
  end

IO.puts("General Discussion topic ID: #{general_discussion_topic_id}")

alice = Agora.Accounts.get_user_by_email("alice@example.com")
bob = Agora.Accounts.get_user_by_email("bob@example.com")

if !is_nil(general_discussion_topic_id) and !is_nil(alice) and !is_nil(bob) do
  threads_to_insert = [
    %{
      title: "Welcome to Agora!",
      body: "Hello everyone, welcome to our new forum! Feel free to introduce yourselves.",
      user_id: alice.id,
      topic_id: general_discussion_topic_id
    },
    %{
      title: "Forum Rules & Guidelines",
      body: "Please read the rules before posting. Be respectful!",
      user_id: alice.id,
      topic_id: general_discussion_topic_id
    },
    %{
      title: "Favorite Books?",
      body: "What are some of your favorite books you\'ve read recently?",
      user_id: bob.id,
      topic_id: general_discussion_topic_id
    }
  ]

  Enum.each(threads_to_insert, fn thread_attrs ->
    # Check if thread with the same title exists in the same topic
    existing_thread =
      Agora.Repo.get_by(Agora.Forum.Thread,
        title: thread_attrs.title,
        topic_id: thread_attrs.topic_id
      )

    case existing_thread do
      nil ->
        changeset = Agora.Forum.Thread.changeset(%Agora.Forum.Thread{}, thread_attrs)

        case Agora.Repo.insert(changeset) do
          {:ok, thread} ->
            IO.puts("Inserted thread: \"#{thread.title}\"")

          {:error, changeset} ->
            IO.inspect(changeset, label: "Error inserting thread \"#{thread_attrs.title}\"")
        end

      _ ->
        IO.puts("Thread already exists: \"#{thread_attrs.title}\"")
    end
  end)
else
  IO.puts("Could not find required users or topic to seed threads.")
end

IO.puts("Thread seeding finished.")
