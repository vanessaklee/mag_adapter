defmodule MagAdapter.Repo do
  use Ecto.Repo,
    otp_app: :mag_adapter,
    adapter: Ecto.Adapters.Postgres
end
