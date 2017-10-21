# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :happo,
  ecto_repos: [Happo.Repo]

# Configures the endpoint
config :happo, HappoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "i8Ay0dyNzDypg9in1m0mFSW1pcQrhXQOdsdEpH6kGeJSRfcaabL1tUTLA6uSJNeE",
  render_errors: [view: HappoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Happo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use slim format in templates
config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine

# Generated files have .slime extension by default. If you prefer .slim,
# you could add the following line to your config:
config :phoenix_slime, :use_slim_extension, true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
