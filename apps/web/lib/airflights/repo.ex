defmodule Airflights.Repo do
  use Ecto.Repo,
    otp_app: :airflights,
    adapter: Ecto.Adapters.Postgres
end
