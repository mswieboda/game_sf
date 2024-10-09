module GSF
  module Path
    enum Tile
      Empty
      Collidable
    end

    alias Tiles = Array(Array(Tile))
    alias Cell = NamedTuple(row: Int32, col: Int32)
    alias Cells = Array(Cell)

    # uses A* path finding algorithm
    # entity size must be <= tile cell size
    def self.find(entity : Cell, target : Cell, tiles : Tiles) : Cells?
      start = entity
      open_set = Set(Cell).new([start])
      came_from = Hash(Cell, Cell).new
      target_score = Hash(Cell, Int32).new
      final_score = Hash(Cell, Int32).new

      target_score[start] = 0
      final_score[start] =  distance_score(start, target)

      while !open_set.empty?
        # NOTE: also works checking target_score, but maybe final_score is most efficient path?
        current = open_set.min_by { |point| final_score[point] }

        break if current == target

        open_set.delete(current)

        [-1, 0, 1].each do |d_row|
          [-1, 0, 1].each do |d_col|
            next if d_row.zero? && d_col.zero?

            neighbor = {row: current[:row] + d_row, col: current[:col] + d_col}

            next if neighbor[:row] < 0 || neighbor[:row] >= tiles.size
            next if neighbor[:col] < 0 || neighbor[:col] >= tiles.first.size
            next if collides?(tiles, row: neighbor[:row], col: neighbor[:col])

            if !d_row.zero? && !d_col.zero?
              # checks corners for collisions
              next if collides?(tiles, row: current[:row] + d_row, col: current[:col])
              next if collides?(tiles, row: current[:row], col: current[:col] + d_col)
            end

            tentative_target_score = target_score[current] + 1

            next if came_from.has_key?(neighbor) && tentative_target_score >= target_score[neighbor]

            came_from[neighbor] = current
            target_score[neighbor] = tentative_target_score
            final_score[neighbor] = tentative_target_score + distance_score(neighbor, target)

            open_set << neighbor
          end
        end
      end

      path = [] of Cell
      current = target

      while came_from.has_key?(current)
        if current_point = current
          path.unshift(current_point)
        end

        current = came_from[current]

        break if current == start
      end

      path.unshift(start)

      path
    end

    def self.distance_score(a : Cell, b : Cell) : Int32
      d_rows = (a[:row] - b[:row]).abs
      d_cols = (a[:col] - b[:col]).abs

      d_rows + d_cols
    end

    def self.collides?(tiles : Tiles, row : Int32, col : Int32) : Bool
      return true if row < 0 || row > tiles.size
      return true if col < 0 || col > tiles.first.size

      tiles[row][col] == Tile::Collidable
    end
  end
end
