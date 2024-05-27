module GSF
  class Screen
    @@view : SF::View = SF::View.new

    def self.width
      @@view.size.x
    end

    def self.height
      @@view.size.y
    end

    def self.init(window : SF::RenderWindow, width, height)
      window.view = SF::View.new(SF.float_rect(0, 0, width, height))
      @@view = window.view
    end
  end
end
