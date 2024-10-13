module GSF
  class TileMap
    include SF::Drawable

    @texture : SF::Texture
    @vertices : SF::VertexArray

    def initialize
      @texture = SF::Texture.new
      @vertices = SF::VertexArray.new(SF::Quads)
    end

    def initialize(texture_file : String, tile_size : Int32, tiles, rows : Int32, columns : Int32)
      size = SF.vector2(tile_size, tile_size)

      # load the tileset texture
      @texture = SF::Texture.from_file(texture_file)
      @vertices = SF::VertexArray.new(SF::Quads)

      tiles_per_row = @texture.size.x // size.x

      # populate the vertex array, with one quad per tile
      (0...rows).each do |row|
        (0...columns).each do |column|
          # get the current tile number
          tile_index = tiles[columns * row + column]

          # find its position in the tileset texture
          tile_pos = SF.vector2(
            tile_index % tiles_per_row,
            tile_index // tiles_per_row
          )

          destination = SF.vector2(column, row)

          # define its 4 corners and texture coordinates
          { {0, 0}, {1, 0}, {1, 1}, {0, 1} }.each do |delta|
            @vertices.append SF::Vertex.new(
              (destination + delta) * size,
              tex_coords: (tile_pos + delta) * size
            )
          end
        end
      end
    end

    def draw(target, states)
      # apply the texture texture
      states.texture = @texture

      # draw the vertex array
      target.draw(@vertices, states)
    end
  end
end
