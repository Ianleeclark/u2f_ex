# U2fEx

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `u2f_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:u2f_ex, "~> 0.1.0"}
  ]
end
```

### PKIStorage

### Config Value

Next you'll need to update your configuration to set the PKIStorage model:

```elixir
config :u2f_ex,
    pki_storage: PKIStorage,
    app_id: "https://yoursite.com"
```
###### NOTE: The <app_id> should be your site.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/u2f_ex](https://hexdocs.pm/u2f_ex).

