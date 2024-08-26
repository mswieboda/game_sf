require "./styled_text"

module GSF
  class Message
    alias ChoiceData = NamedTuple(key: String, label: String)

    @height : Float32 | Int32
    @typing_timer : Timer
    @animate_timer : Timer
    @cx : Float32 | Int32
    @y : Float32 | Int32

    getter text : StyledText
    getter choice_text : SF::Text
    getter width : Float32 | Int32
    getter? typing
    getter? animate
    getter? show
    getter? hide
    getter pages : Array(Array(Array(SF::Text)))
    getter page_index
    getter sound : SF::Sound
    getter choices : Array(ChoiceData)
    getter choice_index
    getter choice_selected : ChoiceData?
    getter line_height : Float32 | Int32

    Padding = 24
    FontSize = 16
    MaxLines = 4
    LineSpacing = 16
    TypeDuration = 69.milliseconds
    AnimateDuration = 300.milliseconds
    AnimateArrowDuration = 500.milliseconds
    BackgroundColor = SF::Color.new(17, 17, 17, 170)
    TextColor = SF::Color::White
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 4
    ArrowRadius = 16
    ArrowBackgroundColor = SF::Color.new(17, 17, 17)

    def initialize(
      @cx,
      @y = -1,
      bot_y = -1,
      @width = Screen.width,
      message = "",
      @typing = false,
      @animate = false,
      @choices = [] of ChoiceData
    )
      @text = StyledText.new(message, font, font_size)
      @pages = [] of Array(Array(SF::Text))
      @page_index = 0
      @text.line_spacing = line_spacing
      @text.fill_color = text_color

      @choice_text = SF::Text.new("M", font, font_size)

      @height = ((font_size + line_spacing) * max_lines - line_spacing).to_f32

      text_dup = text.dup
      text_dup.string = "M"
      @line_height = text_dup.global_bounds.height + line_spacing

      @typing_timer = Timer.new(type_duration)
      @animate_timer = Timer.new(animate_duration)
      @animate_arrow_timer = Timer.new(animate_arrow_duration)

      @show = false
      @hide = true

      if bot_y >= 0
        @y = (Screen.height - padding * 2 - height - bot_y).to_f32
      end

      @sound = SF::Sound.new
      @choice_index = 0
      @choice_selected = nil

      @pages = get_pages

      reset_message
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

    def arrow_radius
      ArrowRadius
    end

    def arrow_background_color
      ArrowBackgroundColor
    end

    def type_duration
      TypeDuration
    end

    def animate_duration
      AnimateDuration
    end

    def animate_arrow_duration
      AnimateArrowDuration
    end

    def next_page_keys
      [Keys::Enter, Keys::E, Keys::Space]
    end

    def next_page_joystick_buttons
      [Joysticks::A]
    end

    def skip_typing_keys
      [Keys::Escape, Keys::Q, Keys::Backspace, Keys::Delete]
    end

    def skip_typing_joystick_buttons
      [Joysticks::B, Joysticks::Back]
    end

    def next_choice_keys
      [Keys::Tab, Keys::S, Keys::Down]
    end

    def next_choice_joysticks?(joysticks : Joysticks)
      joysticks.left_stick_just_moved_down? || joysticks.d_pad_just_moved_down?
    end

    def previous_choice_keys
      [Keys::W, Keys::Up]
    end

    def previous_choice_joysticks?(joysticks : Joysticks)
      joysticks.left_stick_just_moved_up? || joysticks.d_pad_just_moved_up?
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
    #       like `@@previous_choice_sound_buffer ||= SF::SoundBuffer.from_file("./assets/previous_choice.wav")`
    def previous_choice_sound_buffer : SF::SoundBuffer?
      nil
    end

    def previous_choice_sound_pitch
      # NOTE: override to vary or change the pitch
      # ex: `rand(0.9..1.1)`
      1
    end

    def get_pages
      all_text = text.to_words_and_spaces
      lines = get_lines(all_text)
      lines.in_slices_of(max_lines)
    end

    def animated?
      !animate? || @animate_timer.done?
    end

    def typed?
      !typing? || @typing_timer.done?
    end

    def update(keys : Keys, joysticks : Joysticks)
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

      if typed?
        @animate_arrow_timer.start if !@animate_arrow_timer.started? || @animate_arrow_timer.done?

        if keys.just_pressed?(next_page_keys) || joysticks.just_pressed?(next_page_joystick_buttons)
          play_sound(next_page_sound_buffer, next_page_sound_pitch)

          if page_index >= pages.size - 1 && choices.any?
            @choice_selected = choices[@choice_index]
          else
            next_page_or_hide
          end
        end
      elsif typing? && !@typing_timer.done? && (keys.just_pressed?(skip_typing_keys) || joysticks.just_pressed?(skip_typing_joystick_buttons))
        play_sound(skip_typing_sound_buffer, skip_typing_sound_pitch)

        # forces skipping the animation
        @typing_timer.duration = type_duration
      end

      if page_index >= pages.size - 1 && choices.any? && typed?
        if keys.just_pressed?(next_choice_keys) || next_choice_joysticks?(joysticks)
          play_sound(next_choice_sound_buffer, next_choice_sound_pitch)
          @choice_index += 1
          @choice_index = 0 if @choice_index >= choices.size
        elsif keys.just_pressed?(previous_choice_keys) || previous_choice_joysticks?(joysticks)
          play_sound(previous_choice_sound_buffer, previous_choice_sound_pitch)
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

    def update_data(message : String, choices = [] of ChoiceData)
      @text = StyledText.new(message, font, font_size)
      @pages = get_pages
      @page_index = 0
      @choices = choices

      reset_message
      reset_choice_selected
    end

    def typed_message
      pages[page_index].flat_map { |lines| lines.map(&.string).join }.join("\n")
    end

    def reset_message
      message = typed_message
      @typing_timer = Timer.new(message.empty? ? type_duration : type_duration * message.size)
    end

    def next_page_or_hide
      if page_index < pages.size - 1
        @page_index += 1
        reset_message
        return
      end

      if animate?
        @show = false

        reset_choice_selected
        @animate_timer.start
      else
        hide_reset
      end
    end

    def hide_reset
      @hide = true
      @animate_timer = Timer.new(animate_duration)
      @page_index = 0

      reset_choice_selected
      reset_message
    end

    def reset_choice_selected
      @choice_selected = nil
      @choice_index = 0
    end

    def x
      Screen.x + @cx - width / 2
    end

    def y
      Screen.y + @y
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

    def get_lines(all_text : Array(SF::Text)) : Array(Array(SF::Text))
      lines = [[] of SF::Text]
      line_index = 0
      line_width = 0

      all_text.each_with_index do |text, index|
        line_width += text.global_bounds.width

        if line_width >= @width
          if text.string == " "
            lines << [] of SF::Text
            line_width = 0
          else
            lines << [text]
            line_width = text.global_bounds.width
          end

          line_index += 1
        else
          lines[line_index] << text
        end
      end

      lines
    end

    def draw(window : SF::RenderWindow)
      return if hide?

      draw_border(window)

      return unless show? && animated?

      draw_text(window)

      if typed?
        if page_index >= pages.size - 1 && choices.any?
          draw_choices(window)
        else
          draw_arrow(window)
        end
      end
    end

    def draw_text(window)
      max_index = 0

      if typing?
        message = typed_message
        max_index = (typed_message.size * [@typing_timer.percent, 1].min).to_i
      end

      lines = pages[page_index]
      line_x = x + padding
      word_x = line_x
      word_y = y + padding
      index = 0

      lines.each_with_index do |words, line_index|
        words.each do |word|
          word.position = {word_x, word_y}

          if typing? && index + word.string.size > max_index
            partial_word = word.dup
            partial_word.string = word.string[0..(max_index - index)]

            window.draw(partial_word)

            return
          else
            window.draw(word)

            index += word.string.size
            word_x += word.global_bounds.width
          end
        end

        word_y += line_height
        word_x = line_x
      end
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

      choices.each_with_index do |choice, index|
        @choice_text.string = choice[:label]
        px = x + width + padding * 2 + outline_thickness * 2 + choice_padding
        py = y + (choice_text.global_bounds.height + choice_padding * 3 + outline_thickness * 2) * index
        text_width = choice_text.global_bounds.width

        draw_choice_border(window, px, py, text_width, index == @choice_index)

        choice_text.position = {px + choice_padding, py + choice_padding}

        window.draw(choice_text)
      end
    end

    def draw_choice_border(window, px, py, text_width, selected)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(text_width + choice_padding * 2, choice_text.global_bounds.height + choice_padding * 2)
      rect.fill_color = background_color
      rect.outline_color = selected ? outline_color : background_color
      rect.outline_thickness = outline_thickness
      rect.position = {px, py}

      window.draw(rect)
    end

    def draw_arrow(window)
      radius = arrow_radius
      animate_height = radius * 2

      if @animate_arrow_timer.percent <= 0.5
        animate_y = [@animate_arrow_timer.percent, 1].min * animate_height
      else
        animate_y = animate_height - [@animate_arrow_timer.percent, 1].min * animate_height
      end

      px = x + width / 2 + padding
      py = y + height + padding * 2 - animate_height / 2 + animate_y

      triangle = SF::CircleShape.new(radius, 3)
      triangle.fill_color = arrow_background_color
      triangle.outline_color = outline_color
      triangle.outline_thickness = outline_thickness
      triangle.origin = {radius, radius}
      triangle.position = {px, py}
      triangle.rotation = 180

      window.draw(triangle)
    end
  end

  class BottomCenteredMessage < Message
    BottomPadding = Message::Padding * 3

    def initialize(message = "", typing = true, animate = true, choices = [] of ChoiceData)
      super(
        cx: (Screen.width / 2).to_i,
        bot_y: bottom_padding,
        width: (Screen.width / 2).to_i,
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
