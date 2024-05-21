module GSF
  class Message
    @width : Float32 | Int32
    @height : Float32 | Int32
    @char_height : Float32 | Int32
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
    getter sound : SF::Sound
    getter choices : Array(String)
    getter choice_index
    getter choice_selected : String?

    Padding = 64
    FontSize = 28
    MaxLines = 4
    LineSpacing = 2.25
    TypeDuration = 69.milliseconds
    AnimateDuration = 300.milliseconds
    BackgroundColor = SF::Color.new(17, 17, 17, 170)
    TextColor = SF::Color::White
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 4
    SelectedChoiceTextColor = SF::Color.new(0, 255, 0)

    def initialize(
      @cx,
      @y = -1,
      bot_y = -1,
      @max_width = Screen.width,
      @message = "",
      @typing = false,
      @animate = false,
      @choices = [] of String
    )
      @text = SF::Text.new(message, font, font_size)
      @text.line_spacing = line_spacing
      @text.fill_color = text_color

      text_width = @text.global_bounds.width

      @width = [text_width, @max_width].min
      lines = @width < text_width ? get_lines : [@message]

      @pages = lines.in_slices_of(max_lines)
      @page_index = 0

      @text.string = "M"
      @char_height = @text.global_bounds.height

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

      @sound = SF::Sound.new
      @choice_index = 0
      @choice_selected = nil
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

    def choice_padding
      padding / 4
    end

    def selected_choice_text_color
      SelectedChoiceTextColor
    end

    def type_duration
      TypeDuration
    end

    def animate_duration
      AnimateDuration
    end

    def next_page_keys
      [Keys::Enter, Keys::E, Keys::Space]
    end

    def skip_typing_keys
      [Keys::Escape, Keys::Q, Keys::Backspace, Keys::Delete]
    end

    def next_choice_keys
      [Keys::Tab, Keys::S, Keys::Down]
    end

    def prev_choice_keys
      [Keys::W, Keys::Up]
    end

    # NOTE: this has to be overridden by a custom SF::SoundBuffer
    #       like `@@next_page_sound_buffer ||= SF::SoundBuffer.from_file("./assets/next_page.wav")`
    def next_page_sound_buffer : SF::SoundBuffer?
      nil
    end

    def next_page_sound_pitch
      # NOTE: override to vary or change the pitch
      # ex: `rand(0.9..1.1)`
      1
    end

    # NOTE: this has to be overridden by a custom SF::SoundBuffer
    #       like `@@skip_typing_sound_buffer ||= SF::SoundBuffer.from_file("./assets/skip_page.wav")`
    def skip_typing_sound_buffer : SF::SoundBuffer?
      nil
    end

    def skip_typing_sound_pitch
      # NOTE: override to vary or change the pitch
      # ex: `rand(0.9..1.1)`
      1
    end

    # NOTE: this has to be overridden by a custom SF::SoundBuffer
    #       like `@@next_choice_sound_buffer ||= SF::SoundBuffer.from_file("./assets/next_choice.wav")`
    def next_choice_sound_buffer : SF::SoundBuffer?
      nil
    end

    def next_choice_sound_pitch
      # NOTE: override to vary or change the pitch
      # ex: `rand(0.9..1.1)`
      1
    end

    # NOTE: this has to be overridden by a custom SF::SoundBuffer
    #       like `@@prev_choice_sound_buffer ||= SF::SoundBuffer.from_file("./assets/prev_choice.wav")`
    def prev_choice_sound_buffer : SF::SoundBuffer?
      nil
    end

    def prev_choice_sound_pitch
      # NOTE: override to vary or change the pitch
      # ex: `rand(0.9..1.1)`
      1
    end

    def update(keys : Keys)
      return if hide?
      return if animate? && !@animate_timer.done?

      if show?
        if !@typing_timer.started?
          @typing_timer.start
        end
      else
        hide_reset
        return
      end

      if !typing? || @typing_timer.done?
        if keys.just_pressed?(next_page_keys)
          play_sound(next_page_sound_buffer, next_page_sound_pitch)

          if page_index >= pages.size - 1 && choices.any?
            @choice_selected = choices[@choice_index]
          else
            next_page_or_hide
          end
        end
      elsif typing? && !@typing_timer.done? && keys.just_pressed?(skip_typing_keys)
        play_sound(skip_typing_sound_buffer, skip_typing_sound_pitch)

        # forces skipping the animation
        @typing_timer.duration = type_duration
      end

      if page_index >= pages.size - 1 && choices.any? && (!typing? || @typing_timer.done?)
        if keys.just_pressed?(next_choice_keys)
          play_sound(next_choice_sound_buffer, next_choice_sound_pitch)
          @choice_index += 1
          @choice_index = 0 if @choice_index >= choices.size
        elsif keys.just_pressed?(prev_choice_keys)
          play_sound(prev_choice_sound_buffer, prev_choice_sound_pitch)
          @choice_index -= 1
          @choice_index = choices.size - 1 if @choice_index < 0
        end
      end
    end

    def play_sound(sound_buffer, pitch)
      if buffer = sound_buffer
        sound.buffer = buffer
        return if sound.status.playing?

        sound.pitch = pitch
        sound.play
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

    def reset_message
      @message = pages[page_index].join("\n")
      @typing_timer = Timer.new(@message.empty? ? type_duration : type_duration * @message.size)
      @text.string = typing? ? "" : @message
    end

    def next_page_or_hide
      if page_index < pages.size - 1
        @page_index += 1
        reset_message
        return
      end

      if animate?
        @show = false
        @choice_selected = nil
        @animate_timer.start
      else
        hide_reset
      end
    end

    def hide_reset
      @hide = true
      @animate_timer = Timer.new(animate_duration)
      @page_index = 0
      @choice_selected = nil
      reset_message
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

      if show? && (!animate? || @animate_timer.done?)
        draw_text(window)

        if (!typing? || @typing_timer.done?) && page_index >= pages.size - 1
          draw_choices(window)
        end
      end
    end

    def draw_text(window)
      if typing?
        index = (@message.size * [@typing_timer.percent, 1].min).to_i
        text.string = @message[0..index]
      end

      @text.position = {x + padding, y + padding}

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

    def draw_choices(window)
      return if choices.empty?

      text_color = @text.fill_color

      choices.each_with_index do |choice, index|
        text.string = choice
        px = x + width + padding * 2 + outline_thickness * 2 + choice_padding
        py = y + (@char_height + choice_padding * 3 + outline_thickness * 2) * index
        text_width = text.global_bounds.width

        draw_choice_border(window, px, py, text_width)

        @text.fill_color = selected_choice_text_color if index == @choice_index

        text.position = {px + choice_padding, py + choice_padding}

        window.draw(text)

        # set text color back to normal if it was selected
        @text.fill_color = text_color if index == @choice_index
      end
    end

    def draw_choice_border(window, px, py, text_width)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(text_width + choice_padding * 2, @char_height + choice_padding * 2)
      rect.fill_color = background_color
      rect.outline_color = outline_color
      rect.outline_thickness = outline_thickness
      rect.position = {px, py}

      window.draw(rect)
    end
  end

  class BottomCenteredMessage < Message
    BottomPadding = Message::Padding * 3

    def initialize(message = "", typing = true, animate = true, choices = [] of String)
      test_text = SF::Text.new(" ", font, font_size)
      test_text.line_spacing = line_spacing

      height = test_text.global_bounds.height * max_lines

      super(
        cx: (Screen.width / 2).to_i,
        bot_y: bottom_padding,
        max_width: (Screen.width / 2).to_i,
        message: message,
        typing: typing,
        animate: animate,
        choices: choices
      )
    end

    def bottom_padding
      BottomPadding
    end
  end
end
