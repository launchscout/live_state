---
marp: true
---
# Web components and Phoenix

A play in two acts

---
# Hi
I'm [Chris Nelson](http://twitter.com/superchris). I work at [Gaslight](https://teamgaslight.com/). We are hiring :)

---
# WARNING: Somewhat baked ideas ahead!
---
# A brief history of web apps

---
# Server rendered request/response
* Rails/Phoenix make development fast and easy
* UI responsiveness :(
---

# Javascript client/server
* Amazing UI experience
* Now you get to build two apps :(
* And pick the right Javascript framework :(

---
# LiveView
* The best of both
* Rendered on the server
* Still great UX
---
# When is LiveView not a perfect fit?
* You don't always want everything server-side rendered
  * GoogleMaps, Leaflet
* What's the right level of abstraction when you don't?
* Is there a better way than Hooks or Alpine.js?
* What's the right level of abstraction?
---
# Web Components!
* They are just (custom) HTML elements
* LiveView already renders HTML
* Seems like a fit
---
# Brief aside on Web Components
* Don't be scared!
* All the browsers support them
* Github, IBM, Microsoft, Apple all ship em
---
# How to avoid client-side complexity
* Dumb components
* Set attributes and re-render
* Dispatch Custom Events
---
# LiveView and Custom Events
* Not supported OOTB
* [phoenix-custom-event-hook](https://github.com/gaslight/phoenix-custom-event-hook)
* [Demo](https://github.com/gaslight/phoenix-custom-events-demo) time!
---
# But what if you want a client app?
* PWAs
* Native-wrapped (Phonegap, Cordova)
* Native mobile
---
# What makes building javascript web apps terrible?
* Is it really the javascript?
* Would it still be terrible if it was simple enough?
* What if the client side was just dumb components?
---
# Hosted apps (Shopify)
* You want full UI control
* Customize server side templates
* Write your own you UI and call their API
* Is there a better way?
---
# Redux and GenServers
Pretty much the same if you squint really, really hard.

---
# Redux
```javascript
export default (state = 0, action) => {
  switch (action.type) {
    case 'INCREMENT':
      return state + 1
    case 'DECREMENT':
      return state - 1
    default:
      return state
  }
}
```
---
# GenServer
```elixir

def handle_call(:increment, _from, state) do
  {:reply, :ok, state + 1}
end

def handle_call(:decrement, _from, state) do
  {:reply, :ok, state - 1}
end

```
---
# (action, state) => new_state
---
# What if we move the state to the server?
* Clients dispatch `CustomEvents` as actions
* Listen to new state and re-render
---
# Introducing LiveState
* live_state hex package
* live-state npm
---
# live_state
* `LiveStateChannel` behaviour
* `handle_event` similar to LiveView
---
# live-state npm
* subscribe to state
* push `CustomEvent` over channel
---
# Demo: 
[pretend_store server](https://github.com/superchris/pretend_store_server)
[pretend-store client](https://github.com/superchris/pretend-store)
