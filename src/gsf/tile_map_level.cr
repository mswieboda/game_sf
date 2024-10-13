require "json"

module GSF
  class TileMapLevel
    getter rows : Int32
    getter cols : Int32
    getter tiles : Array(Array(Int32))

    @tile_map : TileMap
    @tiles : Array(Array(Int32))
    @tiles_as_cells : Array(Array(Path::Tile))
    @collidable_tile_types : Array(Int32)

    EmptyString = ""

    def initialize(@rows = 1, @cols = 1)
      @tile_map = TileMap.new
      @tiles = [] of Array(Int32)
      @tiles_as_cells = [] of Array(Path::Tile)
      @collidable_tile_types = [] of Int32
    end

    def tile_size
      1
    end

    def tile_sheet_file
      EmptyString
    end

    def tile_sheet_data_file
      EmptyString
    end

    def tile_map_file
      EmptyString
    end

    def width
      tile_size * cols
    end

    def height
      tile_size * rows
    end

    def init_tiles
      return if tile_map_file.empty? || tile_sheet_file.empty?

      json = JSON.parse(File.open(tile_map_file))
      @rows = json["height"].as_i
      @cols = json["width"].as_i

      # tile data is 1-indexed not 0-indexed so subtract 1
      tiles = json["data"].as_a.map { |j| j.as_i - 1 }
      @tile_map = TileMap.new(tile_sheet_file, tile_size, tiles, rows, cols)
      @tiles = tiles.in_slices_of(cols)

      if json["player_start_row"]? && json["player_start_col"]?
        init_player_start(json["player_start_row"].as_i, json["player_start_col"].as_i)
      end

      return if tile_sheet_data_file.empty?

      json = JSON.parse(File.open(tile_sheet_data_file))

      # sets tiles that are collidable from tile_sheet_data_file json
      if raw_ranges = json.dig("collidables", "ranges")
        # this file is 0-indexed
        ranges = raw_ranges.as_a.map(&.as_a.map(&.as_i))

        ranges.each do |range|
          min, max = range

          @collidable_tile_types += (min..max).to_a
        end
      end

      # converts @tiles to Array((Array(Path::Tile))
      @tiles_as_cells = @tiles.map do |cols|
        cols.map do |tile|
          @collidable_tile_types.includes?(tile) ? Path::Tile::Collidable : Path::Tile::Empty
        end
      end

      init_tile_data(json)
    end

    def init_player_start(row : Int32, col : Int32)
    end

    def init_tile_data(json : JSON::Any)
    end

    def draw(window : SF::RenderWindow)
      window.draw(@tile_map)
    end
  end
end
