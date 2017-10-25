use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :happo, HappoWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :happo, Happo.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "happo_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox


# Reduce crypto difficulty in testing according to comeoinin guideliness
# https://github.com/riverrun/comeonin#installation
config :bcrypt_elixir, :log_rounds, 4

# Configure how to send emails
# ──────────────────────────────────────────────────────────────────────
# No emails are sent, instead a message is sent to the current process
# and can be asserted on with helpers from Bamboo.Test.
config :happo, Happo.Mailer,
  adapter: Bamboo.TestAdapter
