module GSF
  class Screen
    @@window : SF::RenderWindow = SF::RenderWindow.new()

    def self.window
      @@window
    end

    def self.view
      @@window.view
    end

    def self.view=(view : SF::View)
      @@window.view = view
    end

    def self.x
      view.center.x - width / 2
    end

    def self.y
      view.center.y - height / 2
    end

    def self.width
      view.size.x
    end

    def self.height
      view.size.y
    end

    def self.reset_view
      window.view.reset(SF.float_rect(0, 0, width, height))
    end

    def self.center_view
      view = SF::View.new
      view.size = window.view.size
      view.center = {view.size.x / 2, view.size.y / 2}
      window.view = view
    end

    def self.init(window : SF::RenderWindow)
      @@window = window
    end
  end
end
