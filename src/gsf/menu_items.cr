module GSF
  class MenuItems
    alias KeyValue = Tuple(String, String)

    getter menu_items
    getter? use_keyboard
    getter? use_mouse
    getter keys_next
    getter keys_previous
    getter keys_select
    getter mouse_select

    def initialize(
      font : SF::Font,
      items = [] of String,
      size = 72,
      text_color = SF::Color::White,
      text_color_focused = SF::Color::Green,
      initial_focused_index = -1,
      use_keyboard = true,
      use_mouse = false,
      keys_next = [Keys::Down, Keys::S, Keys::RShift, Keys::Tab],
      keys_previous = [Keys::Up, Keys::W, Keys::LShift],
      keys_select = [Keys::Space, Keys::Enter],
      mouse_select = Mouse::Left
    )
      @menu_items = [] of MenuItem
      @use_keyboard = use_keyboard
      @use_mouse = use_mouse
      @keys_next = keys_next
      @keys_previous = keys_previous
      @keys_select = keys_select
      @mouse_select = mouse_select

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

    def selected?(keys, mouse, _joysticks)
      return false unless focused_item

      if use_keyboard?
        keys.just_pressed?(keys_select)
      elsif use_mouse?
        mouse.just_pressed?(mouse_select)
      end
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

    def update(frame_time, keys : Keys, mouse : Mouse)
      menu_items.each(&.update(frame_time))

      keyboard_update(keys) if use_keyboard?
      mouse_update(mouse) if use_mouse?
    end

    def keyboard_update(keys : Keys)
      if keys.just_pressed?(keys_previous)
        if index = menu_items.index(&.focused?) || 0
          new_index = index - 1 >= 0 ? index - 1 : menu_items.size - 1

          menu_items[index].blur
          menu_items[new_index].focus
        end
      elsif keys.just_pressed?(keys_next)
        if index = menu_items.index(&.focused?) || -1
          new_index = index + 1 < menu_items.size ? index + 1 : 0

          menu_items[index].blur
          menu_items[new_index].focus
        end
      end
    end

    def mouse_update(mouse : Mouse)
      menu_items.each do |item|
        item.blur

        item.focus if item.hover?(mouse)
      end
    end

    def draw(window : SF::RenderWindow)
      menu_items.each(&.draw(window))
    end
  end
end
