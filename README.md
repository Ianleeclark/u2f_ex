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

In order to properly use this library, you're going to need to store metadata and public
keys for any user registering their U2F Token. However, u2f_ex will need to retrieve that 
metadata, so you're get to write a glorious new module implementing our storage behaviour.

Check out some example docs here: [PKIStorage Example](https://hexdocs.pm/ecto/Ecto.Repo.html#c:list_key_handles_for_user/1)

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

