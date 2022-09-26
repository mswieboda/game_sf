module GSF
  class SceneEmpty < Scene
    def initialize
      super(:empty)
    end

    def update(frame_time, keys : Keys, mouse : Mouse)
    end

    def draw(window : SF::RenderWindow)
    end
  end
end
