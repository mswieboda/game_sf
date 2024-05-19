module GSF
  class EllipseShape < SF::Shape
    getter radius : SF::Vector2f
    getter point_count : Int32

    def initialize(@radius : SF::Vector2f = SF::Vector2f.new, @point_count : Int = 30)
      super()

      update
    end

    def radius=(radius : SF::Vector2f)
      @radius

      update
    end

    def point_count=(point_count : Int)
      @point_count = point_count

      update
    end

    def get_point(index : Int) : SF::Vector2f
      angle = index * 2 * Math::PI / point_count
      x = Math.cos(angle)
      y = Math.sin(angle)

      # origin is {0, 0}, center is @radius
      @radius + @radius * {Math.cos(angle), Math.sin(angle)}
    end
  end
end

