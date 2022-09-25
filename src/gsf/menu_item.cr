module GSF
  class MenuItem
    getter? focused
    getter label : String
    getter size
    getter text : SF::Text
    getter text_color : SF::Color
    getter text_color_focused : SF::Color

    def initialize(
      x,
      y,
      label,
      font : SF::Font,
      size = 72,
      text_color = SF::Color::White,
      text_color_focused = SF::Color::Green,
      focused = false,
      centered = true
    )
      @focused = focused
      @size = size
      @label = label
      @text = SF::Text.new(label, font, size)
      @text_color = text_color
      @text_color_focused = text_color_focused

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
  end
end
