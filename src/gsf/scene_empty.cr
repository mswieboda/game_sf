module GSF
  class SceneEmpty < Scene
    def initialize
      super(:empty)
    end

    def update(frame_time : Float32, keys : Keys, mouse : Mouse, joysticks : Joysticks)
    end

    def draw(window : SF::RenderWindow)
    end
  end
end
