module GSF
  class MenuItem
    getter? focused
    getter key : String
    getter label : String
    getter size
    getter text : SF::Text
    getter text_color : SF::Color
    getter text_color_focused : SF::Color

    def initialize(
      x,
      y,
      @label,
      @key,
      font : SF::Font,
      @size = 72,
      @text_color = SF::Color::White,
      @text_color_focused = SF::Color::Green,
      @focused = false,
      centered = true
    )
      @text = SF::Text.new(label, font, size)

      if centered
        x -= @text.global_bounds.width / 2
        y -= @text.global_bounds.height / 2
      end

      @text.position = SF.vector2(x, y)

      if focused?
        focus
      else
        blur
      end
    end

    def update(frame_time)
    end

    def draw(window : SF::RenderWindow)
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

    def hover?(mouse : Mouse)
      mouse.x > text.position.x && mouse.x <= text.position.x + text.global_bounds.width &&
        mouse.y > text.position.y && mouse.y <= text.position.y + text.global_bounds.height
    end
  end
end
