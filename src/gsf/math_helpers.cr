module GSF
  module MathHelpers
    extend self

    def distance(x1, y1, x2, y2)
      dist_x = x2 - x1
      dist_y = y2 - y1

      Math.sqrt(dist_x ** 2 + dist_y ** 2)
    end
  end
end
