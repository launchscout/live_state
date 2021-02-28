---
marp: true
---
# Web app communication in Elixir

Some ideas for your consideration

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
* Is there a better way than Hooks?
---
# Web Components
* They are just HTML elements
* LiveView already renders HTML
* Seems like fit
---
# How to avoid client-side complexity
* Dumb components
* Set attributes and re-render
* Dispatch Custom Events
---
# LiveView and Custom Events
* Not supported OOTB
* phoenix-custom-event-hook
* Demo time!
---
# But what if you want a client app?
* PWAs
* Native-wrapped (Phonegap, Cordova)
* Native mobile
---
