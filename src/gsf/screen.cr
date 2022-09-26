module GSF
  class Screen
    @@width = 1
    @@height = 1

    def self.width
      @@width
    end

    def self.height
      @@height
    end

    def self.video_mode
      @@mode ||= SF::VideoMode.desktop_mode
    end

    def self.init(window : SF::RenderWindow)
      @@width = window.size.x
      @@height = window.size.y
    end
  end
end
