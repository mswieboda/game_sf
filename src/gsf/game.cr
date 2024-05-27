module GSF
  abstract class Game
    getter window : SF::RenderWindow
    getter clock : SF::Clock
    getter? exit
    getter stage : Stage

    DefaultBackgroundColor = SF::Color.new(0, 0, 0)

    def initialize(title = "", mode = SF::VideoMode.desktop_mode, style = SF::Style::None)
      if style.fullscreen?
        mode = SF::VideoMode.fullscreen_modes.first
      end

      @window = SF::RenderWindow.new(mode, title, style)

      @window.vertical_sync_enabled = vsync
      @window.joystick_threshold = joystick_threshold
      @window.mouse_cursor_visible = mouse_cursor_visible

      Screen.init(@window, mode.width, mode.height)

      @exit = false
      @clock = SF::Clock.new
      @stage = StageEmpty.new(window)
    end

    def vsync
      true
    end

    def joystick_threshold
      1.0
    end

    def mouse_cursor_visible
      true
    end

    def background_color
      DefaultBackgroundColor
    end

    def run
      while window.open?
        while event = window.poll_event
          event(event)
        end

        window.close if exit?

        frame_time = clock.restart.as_seconds

        update(frame_time)

        window.clear(background_color)

        draw(window)

        window.display
      end
    end

    def event(event)
      case event
      when SF::Event::Resized
        # update the view to the new size of the window
        Screen.init(window, event.width, event.height)
      when SF::Event::Closed
        window.close
      end

      stage.event(event)
    end

    def update(frame_time)
      stage.update(frame_time)

      @exit = true if stage.exit?
    end

    def draw(window : SF::RenderWindow)
      stage.draw(window)
    end
  end
end
