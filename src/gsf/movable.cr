module GSF
  class Movable
    getter x : Int32 | Float32
    getter y : Int32 | Float32
    getter dx : Int32 | Float32
    getter dy : Int32 | Float32
    getter? moved

    def initialize(@x, @y)
      @dx = 0
      @dy = 0
      @moved = false
    end

    def moving?
      !@dx.zero? || !@dy.zero?
    end

    def update_movement(frame_time : Float32)
      @moved = false

      return unless move_with_speed(frame_time, speed)
      return unless move_with_level(level_width, level_height)

      move(dx, dy)
    end

    def move_with_speed(frame_time, speed)
      directional_speed = dx != 0 && dy != 0 ? speed / 1.4142 : speed

      @dx *= (directional_speed * frame_time).to_f32
      @dy *= (directional_speed * frame_time).to_f32

      moving?
    end

    def move(dx, dy)
      jump(x + dx, y + dy)
    end

    def jump(x, y)
      @x = x
      @y = y

      @moved = true
    end

    def draw(window : SF::RenderWindow)
    end
  end
end
