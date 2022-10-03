module GSF
  class Screen
    @@width = 1
    @@height = 1
    @@scaling_factor = 1_f64

    DefaultHeight = 1080

    def self.width
      @@width
    end

    def self.height
      @@height
    end

    def self.scaling_factor
      @@scaling_factor
    end

    def self.video_mode
      @@mode ||= SF::VideoMode.desktop_mode
    end

    def self.init(window : SF::RenderWindow, default_height = DefaultHeight)
      @@width = window.size.x
      @@height = window.size.y
      @@scaling_factor = 1 / (@@height / default_height / 2_f64)
    end
  end
end
