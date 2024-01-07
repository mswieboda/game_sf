module GSF
  class MenuItems
    getter items
    getter? use_keyboard
    getter? use_mouse

    def initialize(
      font : SF::Font,
      labels = [] of String,
      size = 72,
      text_color = SF::Color::White,
      text_color_focused = SF::Color::Green,
      initial_focused_index = -1,
      use_keyboard = true,
      use_mouse = false,
      keys_next = [Key::Down, Key::S, Key::RShift, Key::Tab],
      keys_previous = [Key::Up, Key::W, Key::LShift]
    )
      @items = [] of MenuItem
      @use_keyboard = use_keyboard
      @use_mouse = use_mouse

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
          focused: index == initial_focused_index,
          centered: true
        )
      end
    end

    def self.selected?(keys, mouse)
      return false unless focused

      if use_keyboard?
        keys.just_pressed?([Keys::Space, Keys::Enter])
      elsif use_mouse?
        mouse.just_pressed?(Mouse::Left)
      end
    end

    def focused
      if item = items.find(&.focused?)
        item.label
      end
    end

    def update(frame_time, keys : Keys, mouse : Mouse)
      items.each(&.update(frame_time))

      keyboard_update(keys) if use_keyboard?
      mouse_update(mouse) if use_mouse?
    end

    def keyboard_update(keys : Keys)
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

    def mouse_update(mouse : Mouse)
      items.each do |item|
        item.blur

        item.focus if item.hover?(mouse)
      end
    end

    def draw(window : SF::RenderWindow)
      items.each(&.draw(window))
    end
  end
end
