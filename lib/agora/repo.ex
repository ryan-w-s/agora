defmodule Agora.Repo do
  use Ecto.Repo,
    otp_app: :agora,
    adapter: Ecto.Adapters.SQLite3
end
