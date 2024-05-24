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

If on a Mac or Linux you should be good and the `make` should work from `crsfml`'s shards postinstall. (I don't test on Linux right now, but it should be easier than Windows if it doesn't work.)

Note: if installing on Windows use `shards install --skip-postinstall` instead of `shards install` as the `make` from `crsfml` fails with Windows on a regular shell.
To setup `crsfml` for Windows, checkout the `crsfml` repo, and `git checkout v2.5.3` to make sure it's on the right SFML version. Make sure you have open a `x64 Native Tools Command Prompt for VS 2019` shell (see [video with instructions for VS 2019](https://pryp.in/blog/28/running-crystal-natively-on-windows-building-videogame-examples.html) you only need the VS 2019 portion, can ignore all other crystal/crsfml things it's an old video). Once you've opened a shell on Windows via `x64 Native Tools Command Prompt for VS 2019`, navigate to your `v2.5.3` checked out `crsfml` directory, and inside there run `make`, this will generate all the `.obj` files like `crsfml/audio/ext.obj` that are required. Now, in your game directory, delete all the files/folders in `lib/crsfml` and copy over all the files/folders (except for `.git/`) from your `crsfml` folder. Then `crsfml` should work on Windows, after you follow correct instructions from [Install SFML](https://github.com/oprypin/crsfml#install-sfml) and have all the environment variables set `%PATH%`, `%INCLUDE%`, `%LIB%` to the SFML locations. You should only need to do this once per project. Ideally I'll make a script to do all this so it's easier for windows.

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
./bump.cr patch|minor|major|specific-version
```
then
```
git push
```
and
```
git push --tags
```


## Contributors

- [Matt Swieboda](https://github.com/mswieboda) - creator and maintainer
