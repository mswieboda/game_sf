module GSF
  class Animations
    alias AnimationData = {animation: Animation, flip_horizontal: Bool, flip_vertical: Bool}

    getter name

    @data : Hash(Symbol, AnimationData)

    delegate play, to: animation
    delegate done?, to: animation
    delegate global_bounds, to: animation

    def initialize(name, animation : Animation, flip_horizontal = false, flip_vertical = false)
      @data = Hash(Symbol, AnimationData).new
      @name = name

      add(name, animation, flip_horizontal, flip_vertical)
    end

    def add(name : Symbol, animation : Animation, flip_horizontal = false, flip_vertical = false)
      @data[name] = {
        animation: animation,
        flip_horizontal: flip_horizontal,
        flip_vertical: flip_vertical
      }
    end

    def update(frame_time)
      animation.update(frame_time)
    end

    def draw(window, x, y, flip_horizontal = false, flip_vertical = false)
      animation.draw(
        window,
        x,
        y,
        animation_data[:flip_horizontal],
        animation_data[:flip_vertical]
      )
    end

    def play(name : Symbol)
      @name = name

      animation.restart if animation.done?
    end

    def animation_data
      @data[name]
    end

    def animation
      animation_data[:animation]
    end
  end
end
