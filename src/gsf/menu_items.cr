module GSF
  class MenuItems
    alias KeyValue = Tuple(String, String)

    getter menu_items

    def initialize(
      font : SF::Font,
      items = [] of String,
      size = 72,
      text_color = SF::Color::White,
      text_color_focused = SF::Color::Green,
      initial_focused_index = -1
    )
      @menu_items = [] of MenuItem

      items.each_with_index do |item, index|
        # NOTE: for now centered horizontally and vertically on the whole screen
        x = Screen.width / 2
        y = Screen.height / 2 + index * size * 2 - size * 3

        @menu_items << MenuItem.new(
          x: x,
          y: y,
          key: item.is_a?(KeyValue) ? item[0] : item,
          label: item.is_a?(KeyValue) ? item[1] : item,
          font: font,
          size: size,
          text_color: text_color,
          text_color_focused: text_color_focused,
          focused: index == initial_focused_index,
          centered: true
        )
      end
    end

    def keyboard?
      true
    end

    def joysticks?
      true
    end

    def mouse?
      false
    end

    def keys_next
      [Keys::Down, Keys::S]
    end

    def keys_previous
      [Keys::Up, Keys::W]
    end

    def keys_select
      [Keys::Space, Keys::Enter]
    end

    def joysticks_next?(joysticks : Joysticks)
      joysticks.left_stick_just_moved_down? || joysticks.d_pad_just_moved_down?
    end

    def joysticks_previous?(joysticks : Joysticks)
      joysticks.left_stick_just_moved_up? || joysticks.d_pad_just_moved_up?
    end

    def joysticks_select
      [Joysticks::A, Joysticks::Start]
    end

    def mouse_select
      Mouse::Left
    end

    def selected?(keys, joysticks)
      return false unless focused_item
      return true if keyboard? && keys.just_pressed?(keys_select)
      return true if joysticks? && joysticks.just_pressed?(joysticks_select)

      false
    end

    def selected?(keys, mouse, joysticks)
      return false unless focused_item
      return true if keyboard? && keys.just_pressed?(keys_select)
      return true if joysticks? && joysticks.just_pressed?(joysticks_select)
      return true if mouse? && mouse.just_pressed?(mouse_select)

      false
    end

    def focused_key
      if item = menu_items.find(&.focused?)
        item.key
      end
    end

    def focused_label
      if item = menu_items.find(&.focused?)
        item.label
      end
    end

    def focused_item
      if item = menu_items.find(&.focused?)
        {item.key, item.label}
      end
    end

    def update(frame_time : Float32, keys : Keys, joysticks : Joysticks)
      menu_items.each(&.update(frame_time))

      keyboard_update(keys) if keyboard?
      joysticks_update(joysticks) if joysticks?
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      menu_items.each(&.update(frame_time))

      keyboard_update(keys) if keyboard?
      joysticks_update(joysticks) if joysticks?
      mouse_update(mouse) if mouse?
    end

    def previous_item
      if index = menu_items.index(&.focused?) || 0
        new_index = index - 1 >= 0 ? index - 1 : menu_items.size - 1

        menu_items[index].blur
        menu_items[new_index].focus
      end
    end

    def next_item
      if index = menu_items.index(&.focused?) || -1
        new_index = index + 1 < menu_items.size ? index + 1 : 0

        menu_items[index].blur
        menu_items[new_index].focus
      end
    end

    def keyboard_update(keys : Keys)
      if keys.just_pressed?(keys_previous)
        previous_item
      elsif keys.just_pressed?(keys_next)
        next_item
      end
    end

    def joysticks_update(joysticks : Joysticks)
      if joysticks_previous?(joysticks)
        previous_item
      elsif joysticks_next?(joysticks)
        next_item
      end
    end

    def mouse_update(mouse : Mouse)
      menu_items.each do |item|
        item.blur

        item.focus if item.hover?(mouse)
      end
    end

    def draw(window : SF::RenderWindow, x_offset = 0, y_offset = 0)
      menu_items.each(&.draw(window, x_offset, y_offset))
    end
  end
end
