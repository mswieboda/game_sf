module GSF
  class Screen
    @@window : SF::RenderWindow?

    def self.window : SF::RenderWindow
      @@window.as(SF::RenderWindow)
    end

    def self.view
      window.view
    end

    def self.view_top_left
      x = view.center.x - view.size.x / 2
      y = view.center.y - view.size.y / 2

      {x, y}
    end

    def self.x
      view_top_left[0]
    end

    def self.y
      view_top_left[1]
    end

    def self.width
      view.size.x
    end

    def self.height
      view.size.y
    end

    def self.reset_view
      window.view = SF::View.new(SF.float_rect(0, 0, width, height))
    end

    def self.init(window : SF::RenderWindow, width, height, target_height : UInt32? = nil)
      @@window = window

      if t_height = target_height
        if height > t_height
          ratio = (height / t_height).ceil.to_i
          width = (width / ratio).to_i
          height = (height / ratio).to_i
        end
      end

      window.view = SF::View.new(SF.float_rect(0, 0, width, height))
    end
  end
end
