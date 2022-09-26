module GSF
  class Mouse
    alias Button = SF::Mouse::Button

    Util.extract SF::Mouse::Button

    getter x
    getter y

    def initialize(x = 0, y = 0)
      @x = x
      @y = y
      @buttons = Hash(Button, ButtonState).new
    end

    def moved(event : SF::Event::MouseMoved)
      @x = event.x
      @y = event.y
    end

    def reset
      @buttons.each do |(button, state)|
        state.seen unless state.seen?
      end
    end

    def pressed(button : Button)
      if @buttons.has_key?(button)
        @buttons[button].pressed
      else
        @buttons[button] = ButtonState.new(pressed: true)
      end
    end

    def released(button : Button)
      if @buttons.has_key?(button)
        @buttons[button].released
      else
        @buttons[button] = ButtonState.new(pressed: false)
      end
    end

    def pressed?(button : Button)
      @buttons.has_key?(button) && @buttons[button].pressed?
    end

    def pressed?(buttons : Array(Button))
      buttons.any? { |button| pressed?(button) }
    end

    def any_pressed?
      @buttons.any? do |(button, state)|
        state.pressed?
      end
    end

    def just_pressed?(button : Button)
      @buttons.has_key?(button) && @buttons[button].just_pressed?
    end

    def just_pressed?(buttons : Array(Button))
      buttons.any? { |button| just_pressed?(button) }
    end

    def any_just_pressed?
      @buttons.any do |(button, state)|
        state.just_pressed?
      end
    end
  end

  class ButtonState
    getter? pressed
    getter? seen

    def initialize(pressed)
      @pressed = pressed
      @seen = false
    end

    def pressed
      @seen = pressed? && seen?
      @pressed = true
    end

    def released
      @pressed = false
    end

    def seen
      @seen = true
    end

    def just_pressed?
      pressed? && !seen?
    end
  end
end
