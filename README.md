# game_sf

Wrapper / helpers for making a game with SFML using [`crsfml`](https://github.com/oprypin/crsfml)

## Installation

1. [Install SFML](https://github.com/oprypin/crsfml#install-sfml)

2. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     game_sf:
       github: mswieboda/game_sf
   ```

3. Run `shards install`

### Windows

if compiling/installing from Windows, please clone [`crsfml`](https://github.com/oprypin/crsfml)
in the same directory you have this repo, so:

```
C:\some_dir\code
C:\some_dir\code\crsfml
C:\some_dir\code\shoot

```

because for Windows, when installing `crsfml` via `shards install`, `make` doesn't execute correctly, so I am requiring
`crsfml` relatively for windows for now, instead of the normal shard usage. I may fork `crsfml` in the future so this isn't required, but for now it's a decent workaround.

## Usage

```crystal
require "game_sf"
```

## Contributing

1. Fork it (<https://github.com/mswieboda/game_sf/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Matt Swieboda](https://github.com/mswieboda) - creator and maintainer
