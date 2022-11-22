import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :livestate_testbed, LivestateTestbedWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "jlDiNffMPYHH4hnx9xGQkL21UgZxdP1KThYX1gVVkQzb7lqiXzagtormu9/ucuZ0",
  server: true,
  watchers: [
    # node: ["node_modules/vite/bin/vite.js", "build", "--watch", cd: "assets"]
  ]

# In test we don't send emails.
config :livestate_testbed, LivestateTestbed.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :wallaby,
  otp_app: :livestate_testbed,
  base_url: "http://localhost:4002"
  # chromedriver: [
  #   headless: false
  # ]
