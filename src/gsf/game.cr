module GSF
  abstract class Game
    getter window : SF::RenderWindow
    getter clock : SF::Clock
    getter? exit
    property background_color : SF::Color
    getter stage : Stage

    DefaultBackgroundColor = SF::Color.new(0, 0, 0)

    def initialize(
      title = "",
      mode = SF::VideoMode.desktop_mode,
      style = SF::Style::None,
      vsync = true,
      background_color = DefaultBackgroundColor,
      default_width = Screen::DefaultWidth,
      default_height = Screen::DefaultHeight
    )
      @window = SF::RenderWindow.new(mode, title, style)
      window.vertical_sync_enabled = vsync

      Screen.init(window, default_width, default_height)

      @background_color = background_color
      @exit = false
      @clock = SF::Clock.new
      @stage = StageEmpty.new(window)
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
