module GSF
  class Screen
    def self.width
      video_mode.width
    end

    def self.height
      video_mode.height
    end

    def self.video_mode
      @@mode ||= SF::VideoMode.desktop_mode
    end
  end
end
