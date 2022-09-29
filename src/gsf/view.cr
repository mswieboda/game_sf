module GSF
  class View
    protected getter window : SF::RenderWindow
    protected getter view : SF::View

    delegate center, to: @view
    delegate move, to: @view
    delegate rotate, to: @view
    delegate rotation, to: @view
    delegate size, to: @view
    delegate viewport, to: @view
    delegate zoom, to: @view

    def initialize(window : SF::RenderWindow, view : SF::View = window.default_view)
      @window = window
      @view = view
    end

    def initialize(window : SF::RenderWindow, x = 0, y = 0, width = Screen.width, height = Screen.height)
      @window = window
      @view = SF::View.new(SF.float_rect(x, y, width, height))
    end

    def self.from_default(window : SF::RenderWindow)
      new(window, window.default_view)
    end

    def self.from(window : SF::RenderWindow)
      new(window, window.view)
    end

    def set_current
      window.view = view
    end

    def set_default_current
      window.view = window.default_view
    end

    def reset(x = 0, y = 0, width = Screen.width, height = Screen.height)
      @view.reset(SF.float_rect(x, y, width, height))
    end

    def viewport(x, y, width, height)
      @view.viewport = SF.float_rect(x, y, width, height)
    end

    def center(x, y)
      @view.center = {x, y}
    end

    def dup
      self.class.new(window, @view.dup)
    end

    def rotate(degrees)
      @view.rotation = degrees
    end

    def resize(width, height)
      @view.size = {width, height}
    end
  end
end
