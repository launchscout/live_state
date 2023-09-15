# LiveState Tutorial

In this tutorial, we'll be building an embedded app with LiveState. In our example, we'll pretend we are working for a SAAS CRM product company: PipeSpot. Our team is tasked with building a new contact form that can be added to the websites of PipeSpot users.

## What's an embedded app?

I'm so glad you asked! An embedded app is designed to live inside a larger app. For our purposes the larger app is a customers website, and the embedded app is the PipeSpot contact form. 

# How will this work?

In this tutorial, we'll be creating custom element called `<contact-form>` that we'll be able to place on any PipeSpot customer website. It will be responsible for sending the contact's information to pipespot, and display a success message to the user upon completion. LiveState will allow us to keep our code surprisingly simple. Rather than needing a complicated front end framework, our front end code will only need to do two things:

1. Render state
2. Dispatch events

## Let's get started!

LiveState is a library that you add to a phoenix application, so to start we'll want to create a brand new phoenix app. You'll need to follow the instructions to instal phoenix on your system. Once you've done that, you can run:

```
mix phx.new pipe_spot
```

This will take just a minute to fetch the dependencies and compile. It will also give you some instructions for creating a database. You should do what it says :)

### Add live_state dependency

After creating our app, we'll want to add the live_state package as a dependency. Add an
entry for it in the `deps` function of mix.exs:

```elixir
def deps do
  [
    ...
    {:live_state, "~> 0.7"},
    {:cors_plug, ">= 0.0.0"}
  ]
end
```

In order to serve the javascript for the custom element we'll be building from the phoenix app, we'll also need to add `CORSPlug` to our endpoint. Just add a line to `endpoint.ex`:

```elixir
defmodule PipeSpotWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :pipe_spot

  plug CORSPlug
  ...
```

## Generating our Contacts context

The next step is to create the Contacts schema and context so our contacts will have a place to live in the database. For now, we'll keep things *super* simple and say a contact has a name, email, and phone number. We can use the phoenix generators to help us:

```
mix phx.gen.context Contacts Contact contacts name:string email:string phone_number:string
```

This will create the basics CRUD functions we need to work with Contacts. Don't forget to run `mix ecto.migrate` to create the database table.

## Creating our `<contact-form>`

Now we're ready to start building our contact form custom element. Before we start, we'll want to add an additional esbuild config that will keep our custom element code separate from the rest of the app. This will let us easily serve it to our clients without needing to do the additional step of publishing an npm package.

### Setup

To do this, crack open `config.exs` and add the following add a `:custom_elements` section to the end of your esbuild config:

```elixir
config :esbuild,
  default: [
    ...
  ],
  custom_elements: [
    args:
      ~w(js/custom_elements.ts --bundle --target=es2020 --format=esm --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]
```

We'll want to add a watcher in our `dev.exs` as well. Add this line to the `watchers` section of your endpoint config:

```elixir
    esbuild_custom_elements: {Esbuild, :install_and_run, [:custom_elements, ~w(--sourcemap=inline --watch)]},
```

### Creating the element

To create our `<contact-form>` custom element, we'll use a generator to help us out:

```
mix live_state.gen.element ContactForm contact-form
```

This will generate an element for us in `app/js/contact-form.ts`. While LiveState itself is not tied to any specific library, for the purposes of convenience we generate an element based on the [lit](https://lit.dev) library. The generator will also install the necessary npms for you.

We'll also want to add an import for our element in `app/js/custom_elements.js`. You'll want to create this file if it doesn't exit. Add this line for the import:

```javascript
import './contact-form.js'
```

### Render state, dispatch events

As we mentioned earlier, the goal of LiveState is to keep our front end code simple. For our ContactForm element, our state is very simple indeed. To start with, we'll have a single property, `complete`, which will determine if we need to display the contact form or the success message. First, we'll add a `complete` field to hold this state, and tell `LiveState` we want it to be the source of this property. Here's the code we need to add the body of our element class:

```typescript
  @state()
  @liveStateProperty()
  complete: Boolean = false;
```

The redundant looking decorators are necessary because the `@state` decorator tells lit that this property should trigger re-renders on change. The `@liveStateProperty()` decorator tells LiveState to manage this property for us. LiveState is deliberately decoupled from Lit: we can use any library (or none at all!) with LiveState.

Next, we need to implement our `render` method:

```typescript
  render() {
    if (this.complete) {
      return html`<div>Thank you for being a friend :)</div>`
    } else {
      return html`
        <div>Please to give us your precious data</div>
        <form @submit=${this.submitForm}>
          <div>
            <label>Name</label>
            <input name="name" required />
          </div>
          <div>
            <label>Email</label>
            <input name="email" type="email" required />
          </div>
          <div>
            <label>Phone Number</label>
            <input name="phone_number" required />
          </div>
        </form>
      `;
    }
  }
```

For the form to work, we also need to to implement the `submitForm` method. We'll want to grab the form data and dispatch a 'create-contact' CustomEvent which we'll tell LiveState we want to send. Here's what the `submitForm` method looks like:

```typescript
  submitForm(e: SubmitEvent) {
    e.preventDefault();
    const form = e.target as HTMLFormElement;
    const formData = new FormData(form);
    const data = Object.fromEntries(formData.entries());
    this.dispatchEvent(new CustomEvent('create-contact', { detail: data }));
  }
```

And finally we'll need to add this new custom event to our `@liveState` decorator config:

```ts
@liveState({
  events: {
    send: ['create-contact']
  }
  topic: 'contact_form:all'
})
```

## Creating our Channel

The backend of a LiveState application is a Phoenix Channel that implements the LiveState.Channel behaviour. Our channel is responsible for managing the state of our application and providing it to our front end: in this case, our `<contact-form>` custom element. It receives events from the front end. Events may result in a new state, and any state changes are pushed to the front end over the channel. This keeps our front end code nice and simple, because it only needs to render the current state and dispatch events. 

To create the channel, we can use the live_state channel generator like so:

```
mix live_state.gen.channel ContactForm
```

When it asks, we can let it go ahead and create the socket for us and add the channel to it. We'll need to add this new socket to our endpoint:

```elixir
  socket "/live_state", PipeSpotWeb.LiveStateSocket
```

## Creating contacts

To implement our channel, we need to add callbacks to build the intial state and handle our `create-contact` event that is dispatched from the `<contact-form>` element. The initial state is returned in the `init` callback like so:

```elixir
  @impl true
  def init(_channel, _params, _socket) do
    {:ok, %{complete: false}}
  end
```

To create our contact, we'll use the context module we generated earlier and call it in the `handle_event` callback. The payload from the `create-contact` event will have exactly what we need to give to `Contacts.create_contact`. Here's the code we need:

```elixir
  @impl true
  def handle_event("create-contact", contact_attrs, state) do
    case Contacts.create_contact(contact_attrs) do
      {:ok, _contact} -> {:noreply, Map.put(state, :complete, true)}
      {:error, _} -> {:noreply, state}
    end
  end
```

## Taking our `<contact-form>` for a spin

At this point, we have everything in place to be able use our custom element on a page. To do so, you can write are the simplest possible html file that uses the element like so:

```html
<html>

<head>
  <script type="module" src="http://localhost:4000/assets/custom_elements.js"></script>
</head>

<body>
  <contact-form url="ws://localhost:4000/live_state"></contact-form>
</body>

</html>
```

To see it in action, make sure you start up the phoenix app with `mix phx.server`. We're presuming it's listening on the standard port (4000). You can then just open the html file in your browser. You don't even need a server at all. This proves the main advantage of an embedded app: you really can serve it from anywhere (or nowhere!).

You should be able fill out the form, submit it, and see a helpful thank you message!

## Next steps

There's a lot more we'd probably like to do. We currently don't have any error handling. We've marked all our fields as required so the browser will do some validation for us, but to make things better we we would need to parse errors from changeset and add them to the state on our custom element. We'll tackle that in a future installment.

## I just wanna see the answer...

The completed code for this tutorial is [here](https://github.com/launchscout/pipe_spot).
