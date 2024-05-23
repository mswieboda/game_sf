require "./version"
require "option_parser"

module GSF
  ShardFile = "shard.yml"
  VersionFile = "src/version.cr"

  class Bump
    @prev_version = ""
    @version = ""
    @action = ""

    def get_current_version
      file = File.read(ShardFile)
      find = "\nversion: "
      start_index = (file.index(find) || 0) + find.size - 1
      end_index = file.index("\n", start_index)
      file[start_index..end_index].strip
    end

    def new_version
      arg = ARGV.empty? ? "patch" : ARGV.first
      @action = arg

      if arg == "patch"
        parts = @prev_version.split(".")
        parts[2] = (parts[2].to_i + 1).to_s
        parts.join(".")
      elsif arg == "minor"
        parts = @prev_version.split(".")
        parts[1] = (parts[1].to_i + 1).to_s
        parts[2] = "0"
        parts.join(".")
      elsif arg == "major"
        parts = @prev_version.split(".")
        parts[0] = (parts[0].to_i + 1).to_s
        parts[1] = "0"
        parts[2] = "0"
        parts.join(".")
      else
        @action = "version"

        arg
      end
    end

    def replace_versions
      puts "replacing version..."

      # shard.yml
      replace_text(
        file_name: ShardFile,
        find: "name: game_sf\nversion: #{@prev_version}",
        replace: "name: game_sf\nversion: #{@version}"
      )

      # version.cr
      replace_text(
        file_name: VersionFile,
        find: "VERSION = \"#{@prev_version}\"",
        replace: "VERSION = \"#{@version}\""
      )
    end

    def replace_text(file_name, find, replace)
      File.write(file_name, File.read(file_name).sub(find, replace))
    end

    def git_commit
      puts "git commit -am \"Version v#{@version}\""
      Process.run("git", ["commit", "-am", "Version v#{@version}"], output: STDOUT)
    end

    def git_tag
      puts "git tag v#{@version}"
      Process.run("git", ["tag", "v#{@version}"], output: STDOUT)
    end

    def run
      @prev_version = get_current_version
      @version = new_version

      puts "#{@action} v#{@prev_version} -> v#{@version}"

      replace_versions
      git_commit
      git_tag

      puts "v#{@version} replaced, committed, tagged"
    end
  end
end

GSF::Bump.new.run
