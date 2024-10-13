module GSF
  class Animations
    alias AnimationData = {animation: Animation, flip_horizontal: Bool, flip_vertical: Bool}

    getter name

    @data : Hash(Symbol, AnimationData)

    delegate play, to: animation
    delegate pause, to: animation
    delegate done?, to: animation
    delegate global_bounds, to: animation

    def initialize(@name : Symbol)
      @data = Hash(Symbol, AnimationData).new
    end

    def initialize(@name : Symbol, animation : Animation, flip_horizontal = false, flip_vertical = false)
      @data = Hash(Symbol, AnimationData).new

      add(name, animation, flip_horizontal, flip_vertical)
    end

    def add(name : Symbol, animation : Animation, flip_horizontal = false, flip_vertical = false)
      @data[name] = {
        animation: animation,
        flip_horizontal: flip_horizontal,
        flip_vertical: flip_vertical
      }
    end

    def update(frame_time : Float32)
      animation.update(frame_time)
    end

    def draw(window, x, y, color : SF::Color? = nil, rotation = 0)
      animation.draw(
        window,
        x,
        y,
        animation_data[:flip_horizontal],
        animation_data[:flip_vertical],
        color,
        rotation
      )
    end

    def play(name : Symbol)
      @name = name

      animation.play
      animation.restart if animation.done?
    end

    # NOTE: is not working when looping is enabled, needs a fix for that
    def pause_after_done
      animation.pause if animation.done?
    end

    def animation_data
      @data[name]
    end

    def animation
      animation_data[:animation]
    end
  end
end
