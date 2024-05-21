require "./version"
require "option_parser"

module GSF
  ShardFile = "shard.yml"
  VersionFile = "src/version.cr"

  class Bump
    @version : String = GSF::VERSION

    def parse_version
      arg = ARGV.empty? ? "patch" : ARGV.first

      if arg == "patch"
        parts = @version.split(".")
        parts[2] = (parts[2].to_i + 1).to_s
        parts.join(".")
      elsif arg == "minor"
        parts = @version.split(".")
        parts[1] = (parts[1].to_i + 1).to_s
        parts[2] = "0"
        parts.join(".")
      elsif arg == "major"
        parts = @version.split(".")
        parts[0] = (parts[0].to_i + 1).to_s
        parts[1] = "0"
        parts[2] = "0"
        parts.join(".")
      else
        arg
      end
    end

    def replace_versions
      # shard.yml
      replace_text(
        file_name: ShardFile,
        find: "name: game_sf\nversion: #{GSF::VERSION}",
        replace: "name: game_sf\nversion: #{@version}"
      )

      # version.cr
      replace_text(
        file_name: VersionFile,
        find: "VERSION = \"#{GSF::VERSION}\"",
        replace: "VERSION = \"#{@version}\""
      )
    end

    def replace_text(file_name, find, replace)
      File.write(file_name, File.read(file_name).sub(find, replace))
    end

    def git_commit
      # `git commit -am "Version v#{@version}"`
      Process.new("git", ["commit", "-am", "Version v#{@version}"], output: STDOUT)
    end

    def git_tag
      `git tag v#{@version}`
    end

    def run
      @version = parse_version

      replace_versions
      git_commit
      git_tag
    end
  end
end

GSF::Bump.new.run
