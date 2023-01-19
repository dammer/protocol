# devtools protocol version 1.3 for Crystal

Converted from official ChromeDevTools repo [json](https://github.com/ChromeDevTools/devtools-protocol/tree/master/json) files

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     protocol:
       github: dammer/protocol
   ```

2. Run `shards install`

## Usage

```crystal
require "protocol"
```

```crystal
def process_message(raw : String)
  m = NamedTuple(id: UInt64?, method: String?).from_json(raw)
  if cmd_id = m[:id]
    emit CommandEvent, cmd_id, raw
  else
    event = map_events(m) # Protocol::EVENTS_MAP[name]
    {% begin %}
      case event
      {% for _, event in Protocol::EVENTS_MAP %}
        when {{ event }}.class
          emit {{event}}, Protocol::{{event}}.from_json(raw, root: "params")
      {% end %}
      end
    {% end %}
   end
end
```

## Contributing

1. Fork it (<https://github.com/dammer/protocol/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Damir Sharipov](https://github.com/your-github-user) - creator and maintainer
