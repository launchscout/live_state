# LivestateTestbed

To run the testbed application run the following commands from the `live_state/testbed/` directory:

  * Install Livestate testbed elixir dependencies with `mix deps.get`
  * Install Livestate testbed javascript dependencies with `npm install --prefix assets`

  * Install dependencies for phx-live-state and build  `cd ../phx-live-state/ && npm install && npm run build && cd -`
  * Install dependencies for use-live-state and build  `cd ../use-live-state/ && npm install && npm run build && cd -`

  * Build Livestate javascript with `mix esbuild default`

  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
