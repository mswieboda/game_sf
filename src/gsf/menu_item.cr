module GSF
  class MenuItem
    getter x : Int32 | Float32
    getter y : Int32 | Float32
    getter? focused
    getter key : String
    getter label : String
    getter text : SF::Text
    getter text_color : SF::Color
    getter text_color_focused : SF::Color

    def initialize(
      @x,
      @y,
      @label,
      @key,
      font : SF::Font,
      size = 72,
      @text_color = SF::Color::White,
      @text_color_focused = SF::Color::Green,
      @focused = false,
      centered = true
    )
      @text = SF::Text.new(label, font, size)

      if centered
        @x -= @text.global_bounds.width / 2
        @y -= @text.global_bounds.height / 2
      end

      @text.position = {@x, @y}

      if focused?
        focus
      else
        blur
      end
    end

    def update(frame_time : Float32)
    end

    def draw(window : SF::RenderWindow, x_offset = 0, y_offset = 0)
      unless x_offset.zero?
        @text.position = {@x + x_offset, @text.position.y}
      end

      unless y_offset.zero?
        @text.position = {@text.position.x, @y + y_offset}
      end

      window.draw(text)
    end

    def focus
      @focused = true
      @text.fill_color = text_color_focused
    end

    def blur
      @focused = false
      @text.fill_color = text_color
    end

    # TODO: this is probably broken if draw x_offset or y_offset is used
    def hover?(mouse : Mouse)
      mouse.x > text.position.x && mouse.x <= text.position.x + text.global_bounds.width &&
        mouse.y > text.position.y && mouse.y <= text.position.y + text.global_bounds.height
    end
  end
end
