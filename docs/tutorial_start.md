# LiveState Tutorial

In this tutorial, we'll be building an embedded app with LiveState. In our example, we'll pretend we are working for a SAAS CRM product company: PipeSpot. Our team is tasked with building a new contact form that can be added to the websites of PipeSpot users.

## What's an embedded app?

I'm so glad you asked! An embedded app is designed to live inside a larger app. For our purposes the larger app is a customers website, and the embedded app is the PipeSpot contact form.

## Let's get started!

LiveState is a library that you add to a phoenix application, so to start we'll want to create a brand new phoenix app. You'll need to follow the instructions to instal phoenix on your system. Once you've done that, you can run:

```
mix phx.new pipe_spot
```

This will take just a minute to fetch the dependencies and compile. It will also give you some instructions for creating a database. You should do what it says :)

## Generating our Contacts context

The next step is to create the Contacts schema and context so our contacts will have a place to live in the database. For now, we'll keep things *super* simple and say a contact has a name, email, and phone number. We can use the phoenix generators to help us:

