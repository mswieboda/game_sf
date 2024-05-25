module GSF
  class Screen
    @@view : SF::View = SF::View.new

    DefaultWidth = 1920_f32
    DefaultHeight = 1080_f32

    def self.width
      @@view.size.x
    end

    def self.height
      @@view.size.y
    end

    def self.init(window : SF::RenderWindow, default_width = DefaultWidth, default_height = DefaultHeight)
      @@view = window.view

      @@view.reset(SF.float_rect(0_f32, 0_f32, default_width, default_height))
    end
  end
end
