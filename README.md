<p>
  <img src="https://cloud.githubusercontent.com/assets/464900/15801312/1cf60030-2a5f-11e6-8470-085779e78046.png" height="65" />
</p>

[![Travis](https://travis-ci.org/simonprev/solage.svg?style=flat-square)](https://travis-ci.org/simonprev/solage)

Provides basic functionalities to implement a [JSON API](http://jsonapi.org)-compliant API.

* [Installation](#installation)
* [Why?](#why-)
* [Description](#description)
    - [QueryConfig](#solage-queryconfig)
    - [Serializer](#solage-serializer)
    - [DataTransform](#solage-datatransform)
    - [AttributeTransform](#solage-attributetransform)
* [Examples](#examples)

## Installation

Add `solage` to the `deps` function in your project’s `mix.exs` file:

```elixir
defp deps do
  [
    …,
    {:solage, "> 0.0.0"}
  ]
end
```

Then run `mix do deps.get, deps.compile` inside your project’s directory.

## Why?

While implementing a JSON API-compliant API in Elixir, I stumbled upon two great packages: `JaSerializer` and `jsonapi`.
With great respect to their maintainers, I found three problems with those packages:

- Restrictive and unextensible Domain-Specific-Language
- URL guessing
- Missing query restriction, or restriction at the wrong place _(Which relation can be included, which filters are permitted)_

At first I tried to contribute to the packages but I thought that it could be a good exercise to implement those things myself :P
*A lot* of what is implemented comes directly from those two packages. Thanks again for the cleverness of their maintainers.

## Description

This package doesn’t implement the whole view with `id`, `type`, `attributes` or `relationships`.
It lets your application define this stuff. It’s a bit more of boilerplate code to write but you’ll never have to
bend or hook you in a restrictive DSL. This means you can implement an API with nested resources and not use the `included` feature.
You would benefit from awesome features such as preload parsing, sort parsing, etc. Those concepts are good on their own without
attaching the whole JSON API specification in front of it. This is what this package is aiming for.

- Don’t want to provide unecessary routes? This package won’t invent routes for your app.
- Want to implement sparse fields on a certain view? With the `render/3` function, you have all the tools to implement this kind of thing.
- Want to embed a certain assocation on the object data? You get the point.

## Solage.QueryConfig

By using the `QueryConfig`, you don’t have to hardcode data behaviour right in the view. It’s up to who
is rendering the view to use a config that fits your need. The config can be initialized with the `Solage.Query` plug.

### What’s inside QueryConfig

- `include`: List all includes required by the request. With options set at the plug level, you can add `always_includes` or whitelist includes with `allowed_includes`. The output is compliant to a `MyApp.Repo.preload/2` function call (easy integration with Ecto!). The include is used to build the `included` structure found in a JSON API response.
- `sort`: List that looks like `[asc: :attribute, desc: :other_attribute]`. Like the `include` option, you can specify options at the plug level to allow specific sort params.
- `filter`: Map that can be filtered like the above options.
- `fields`: Map that contains fields that need to be in the resource data.

## Solage.Serializer

Use the `Serializer` to render the `data` and `included` section of the JSON API. You only need a view that implements `render/3` and you’re ready to go.
To obtain the relation view of an included resource, you will need to implement `relation_view/1` that receive the relation name as an atom.

### What’s inside Serializer

**2 functions**

- `render/4`: Render the representation of a resource. It’s just a proxy for `view.render(data, query_config, conn)`
- `included/4`: With the QueryConfig, parse the data and call `data/4` on each resource. Takes all the rendered resources and put them in a list.

## Solage.DataTransform

The `DataTransform` module provides a quick and extensible way of encoding and decoding data keys. You could use it in a plug
before using the params to replace `-` with `_` on all keys. Or run it on the encoded data before sending the response.

The decoder and encoder are set in the config `:solage, :decoder_formatter` and `:solage, :encoder_formatter`.
Check the `Solage.DataTransform.Transformer` behaviour to implement your own.

### Valid formatters

- `:dasherized` (Default)
- `:nothing` Don’t transform the keys
- Any module that respond to `decode_key/1` and `encode_key/1`

### Examples

```elixir
plug :deserialize_params

defp deserialize_params(conn, _) do
  %{conn | params: Solage.DataTransform.decode(conn.params)}
end
```

## Solage.AttributeTransform

The `AttributeTransform` module provides a clean and extensible way to transform a JSON API payload to a usable flat map like a regular REST API would accept.
You can use the default resolver that assume that your relationship will be the _name of the association_ + `_id` for `belongs_to` associations and _name of the association_ + `_ids` for `has_many` associations.

But the interface could be implemented to support other kind of input. Check the `Solage.AttributeTransform.Transformer` behaviour to implement your own.

### Examples

```elixir
params = {
  "type": "person",
  "attributes": {"first": "Jane", "last": "Doe", "type": "anon"},
  "relationships": {"user": {"data": {"id": 1}}}
}

Solage.AttributeTransform.flatten(params)
# => {
#      "person": {
#        "first": "Jane",
#        "last": "Doe",
#        "type": "anon",
#        "user_id": 1
#      }
#    }
```

## Examples

### Views

```elixir
defmodule PostView do
  def render(data, _config, _conn) do
    %{
      id: data["id"],
      relationships: %{
        user: data["author_id"]
      }
    }
  end

  def relation_view(:author), do: UserView
end

defmodule UserView do
  def render(data, _config, _conn) do
    %{
      id: data["id"],
      full_name: data["fullname"]
    }
  end
end
```

### Endpoint

```elixir
def show(conn, _) do
  # Transform params key with the right format
  conn = %{conn | params: Solage.DataTransform.decode(conn.params)}

  # Render the data value
  data = Solage.Serializer.render(PostView, conn.assigns[:post], conn.assigns[:jsonapi_query], conn)

  # Render the included value
  included = Solage.Serializer.included(PostView, conn.assigns[:post], conn.assigns[:jsonapi_query], conn)

  # Encode the final body with the right format
  body = Solage.DataTransform.encode(%{data: data, included: included})

  # Send the json response
  json(conn, 200, body)
end
```

### Reponse

```json
{
  "included": [
    {
      "id": "my-author-id",
      "full-name": "Testy"
    }
  ],
  "data": [
    {
      "id": "my-post-id",
      "relationships": {
        "author": "my-author-id"
      }
    }
  ]
}
```

## License

Solage is © 2016 Simon Prévost and may be freely distributed under the [MIT license](https://github.com/simonprev/solage/blob/master/LICENSE.md). See the `LICENSE.md` file for more information.
