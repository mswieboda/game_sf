module GSF
  class MenuItems
    getter items

    def initialize(
      font : SF::Font,
      labels = [] of String,
      size = 72,
      text_color = SF::Color::White,
      text_color_focused = SF::Color::Green
    )
      @items = [] of MenuItem

      labels.each_with_index do |label, index|
        # NOTE: for now centered horizontally and vertically on the whole screen
        x = Screen.width / 2
        y = Screen.height / 2 + index * size * 2 - size * 3
        @items << MenuItem.new(
          x: x,
          y: y,
          label: label,
          font: font,
          size: size,
          text_color: text_color,
          text_color_focused: text_color_focused,
          focused: index == 0,
          centered: true
        )
      end
    end

    def focused
      if item = items.find(&.focused?)
        return item.label
      end
    end

    def update(frame_time, keys : Keys, mouse : Mouse)
      items.each(&.update(frame_time))

      if keys.just_pressed?(Keys::Up)
        if index = items.index(&.focused?)
          new_index = index - 1 >= 0 ? index - 1 : items.size - 1

          items[index].blur
          items[new_index].focus
        end
      elsif keys.just_pressed?(Keys::Down)
        if index = items.index(&.focused?)
          new_index = index + 1 < items.size ? index + 1 : 0

          items[index].blur
          items[new_index].focus
        end
      end
    end

    def draw(window : SF::RenderWindow)
      items.each(&.draw(window))
    end
  end
end
