module GSF
  abstract class Scene
    getter name
    getter? exit

    def initialize(name = :base)
      @name = name
      @exit = false
    end

    def init
    end

    def reset
      @exit = false
    end

    abstract def update(frame_time, keys : Keys, mouse : Mouse)

    abstract def draw(window : SF::RenderWindow)
  end
end
