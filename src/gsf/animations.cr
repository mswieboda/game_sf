module GSF
  class Animations
    alias AnimationData = {animation: Animation, flip_horizontal: Bool, flip_vertical: Bool}

    getter animations : Hash(Symbol, AnimationData)
    getter name

    @animation_data : AnimationData | Nil

    def initialize
      @animation_data = nil
      @animations = Hash(Symbol, AnimationData).new
      @name = :none
    end

    def add(name : Symbol, animation : Animation, flip_horizontal = false, flip_vertical = false)
      @animations[name] = {animation: animation, flip_horizontal: flip_horizontal, flip_vertical: flip_vertical}
    end

    def update(frame_time)
      if a = @animation_data
        a[:animation].update(frame_time)
      end
    end

    def draw(window, x, y, flip_horizontal = false, flip_vertical = false)
      if a = @animation_data
        a[:animation].draw(window, x, y, a[:flip_horizontal], a[:flip_vertical])
      end
    end

    def play(name : Symbol)
      @name = name
      @animation_data = animations[name]

      if a = @animation_data
        a[:animation].restart if a[:animation].done?
      end
    end

    def done?
      if a = @animation_data
        a[:animation].done?
      else
        true
      end
    end

    def pause
      if a = @animation_data
        a[:animation].pause
      end
    end
  end
end
