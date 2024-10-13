require "./math_helpers"

module GSF
  struct Box
    property width : Int32
    property height : Int32

    def initialize(size = 1)
      @width = size
      @height = size
    end

    def initialize(@width = 1, @height = 1)
    end

    # with other Box
    def collides?(x, y, other : Box, other_x, other_y)
      # calc right and bottom edges (note x, y are centered)
      right = x + width
      other_right = other_x + other.width
      bottom = y + height
      other_bottom = other_y + other.height

      # check if boxes overlap on both axes
      (x < other_right && right >= other_x) &&
        (y < other_bottom && bottom >= other_y)
    end

    # with circle (cx, cy, radius)
    def collides?(x, y, radius, cx, cy)
      # temporary variables to set edges for testing
      test_x = cx
      test_y = cy

      # which edge is closest?
      if cx < x
        # test left edge
        test_x = x
      elsif cx > x + width
        # right edge
        test_x = x + width
      end

      if cy < y
        # top edge
        test_y = y
      elsif cy > y + height
        # bottom edge
        test_y = y + height
      end

      # get distance from closest edges
      # if distance is less than radius, it collides
      MathHelpers.distance(test_x, test_y, cx, cy) <= radius
    end

    # with circle (cx, cy, radius)
    def collides?(x, y, circle : Circle, cx, cy)
      collides?(x, y, circle.radius, cx, cy)
    end
  end
end
