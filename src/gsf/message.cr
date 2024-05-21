module GSF
  class Message
    @width : Float32 | Int32
    @height : Float32 | Int32
    @typing_timer : Timer
    @animate_timer : Timer

    getter cx : Float32 | Int32
    getter y : Float32 | Int32
    getter message : String
    getter text : SF::Text
    getter max_width : Float32 | Int32
    getter? typing
    getter? animate
    getter? show
    getter? hide
    getter pages : Array(Array(String))
    getter page_index

    Padding = 64
    FontSize = 28
    MaxLines = 4
    LineSpacing = 2.25
    TypeDuration = 69.milliseconds
    AnimateDuration = 300.milliseconds
    BackgroundColor = SF::Color.new(17, 17, 17, 170)
    TextColor = SF::Color::White
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 8

    def initialize(@cx, @y = -1, bot_y = -1, @max_width = Screen.width, @message = "", @typing = false, @animate = false)
      @text = SF::Text.new(message, font, font_size)
      @text.line_spacing = line_spacing
      @text.fill_color = text_color

      text_width = @text.global_bounds.width

      @width = [text_width, @max_width].min
      lines = @width < text_width ? get_lines : [@message]

      @pages = lines.in_slices_of(max_lines)
      @page_index = 0

      @message = pages.first.join("\n")
      @text.string = @message
      @height = @text.global_bounds.height

      @typing_timer = Timer.new(@message.empty? ? type_duration : type_duration * @message.size)
      @text.string = typing? ? "" : @message

      @animate_timer = Timer.new(animate_duration)

      @show = false
      @hide = true

      if bot_y >= 0
        @y = (Screen.height - padding * 2 - height - bot_y).to_f32
      end

      @text.position = {x + padding, y + padding}
    end

    # NOTE: this has to be overridden by a custom font
    def font
      @@font ||= SF::Font.new
    end

    def font_size
      FontSize
    end

    def max_lines
      MaxLines
    end

    def line_spacing
      LineSpacing
    end

    def text_color
      TextColor
    end

    def background_color
      BackgroundColor
    end

    def outline_color
      OutlineColor
    end

    def outline_thickness
      OutlineThickness
    end

    def padding
      Padding
    end

    def type_duration
      TypeDuration
    end

    def animate_duration
      AnimateDuration
    end

    def accept_keys
      [Keys::Enter, Keys::Space, Keys::E]
    end

    def update(keys : Keys)
      return if hide?

      if animate? && @animate_timer.done?
        if show?
          @typing_timer.start if !@typing_timer.started?
        else
          hide_reset
          return
        end
      end

      if keys.just_pressed?(accept_keys)
        if @typing_timer.done?
          next_or_hide
        else
          @typing_timer.duration = type_duration
        end
      end
    end

    def show
      @show = true
      @hide = false

      if animate?
        @animate_timer.start
      else
        @typing_timer.start
      end
    end

    def next_or_hide
      if page_index < pages.size - 1
        @page_index += 1
        @message = pages[page_index].join("\n")
        @typing_timer = Timer.new(@message.empty? ? type_duration : type_duration * @message.size)
        @text.string = typing? ? "" : @message
        return
      end

      if animate?
        @show = false
        @animate_timer.start
      else
        hide_reset
      end
    end

    def hide_reset
      @hide = true
      text.string = typing? ? "" : @message
      @typing_timer = Timer.new(@message.empty? ? type_duration : type_duration * @message.size)
      @animate_timer = Timer.new(animate_duration)
    end

    def x
      cx - width / 2
    end

    def width
      if animate?
        if show?
          @width * [@animate_timer.percent, 1].min
        else
          @width * (1 - [@animate_timer.percent, 1].min)
        end
      else
        @width
      end
    end

    def height
      if animate?
        if show?
          @height * [@animate_timer.percent, 1].min
        else
          @height * (1 - [@animate_timer.percent, 1].min)
        end
      else
        @height
      end
    end

    def get_lines
      lines = [""]
      line_index = 0
      text.string = " "
      char_width = text.global_bounds.width.to_i
      chars_per_line = (@width / char_width).to_i

      message.split.each do |word|
        if lines[line_index].size + word.size > chars_per_line
          line_index += 1
          lines << ""
        end

        lines[line_index] += "#{word} "
      end

      lines
    end

    def draw(window : SF::RenderWindow)
      return if hide?

      draw_border(window)
      draw_text(window) if show?
    end

    def draw_text(window)
      if typing?
        index = (@message.size * [@typing_timer.percent, 1].min).to_i
        text.string = @message[0..index]
      end

      # TODO: try commenting this out
      @text.position = {x + padding, y + padding} if animate?

      window.draw(text)
    end

    def draw_border(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width + padding * 2, height + padding * 2)
      rect.fill_color = background_color
      rect.outline_color = outline_color
      rect.outline_thickness = outline_thickness
      rect.position = {x, y}

      window.draw(rect)
    end
  end

  class BottomCenteredMessage < Message
    BottomPadding = Message::Padding * 3

    def initialize(message = "", typing = true, animate = true)
      test_text = SF::Text.new(" ", font, font_size)
      test_text.line_spacing = line_spacing

      height = test_text.global_bounds.height * max_lines

      super(
        cx: (Screen.width / 2).to_i,
        bot_y: bottom_padding,
        max_width: (Screen.width / 2).to_i,
        message: message,
        typing: typing,
        animate: animate
      )
    end

    def bottom_padding
      BottomPadding
    end
  end
end
