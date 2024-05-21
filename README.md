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

Note: if installing on Windows use `shards install --skip-postinstall` as the `make` from `crsfml` fails with Windows, and the generation is only meant to be ran from a Unix machine. Afterwards manually copy the `crsfml` repo folder into your projects `lib` folder, after the first `shards install --skip-postinstall` that installs `game_sf` and `crsfml`, so you'll only need to do this once. Override any `crsfml` folder in there. Then `crsfml` should work on Windows, assuming your followed correct instructions from [Install SFML](https://github.com/oprypin/crsfml#install-sfml) and have all the environment variables set `%PATH%`, `%INCLUDE%`, `%LIB%` to the SFML locations.

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

### New Release

To make a new release after PRs or features merged, make sure you bump the
version and push the tag. Currently this is done on `master` but might be automated with GitHub Actions/CI or done manually in PRs down the line.

script helper to bump version, commit, and tag:
```
crystal src/bump.cr patch|minor|major|specific-version
```
next
```
git push
```
and
```
git push --tags
```

Automating this step into a script in the future would be nice too, such as:

```
crystal src/bump.cr patch
crystal src/release.cr
```

but that hasn't been done yet.

## Contributors

- [Matt Swieboda](https://github.com/mswieboda) - creator and maintainer
