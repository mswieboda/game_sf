module GSF
  class Joysticks
    alias Axis = SF::Joystick::Axis

    # NOTE: buttons mapped from Xbox 360 controller
    enum Button
      A
      B
      X
      Y
      LeftBumper
      RightBumper
      Back # or Select etc
      Start
      LeftThumb
      RightThumb
    end

    Util.extract GSF::Joysticks::Button

    def initialize
      @joysticks = Hash(UInt32, JoystickState).new
    end

    def reset
      @joysticks.each do |(joystick_id, state)|
        state.reset
      end
    end

    def pressed(joystick_id : UInt32, button : UInt32)
      if @joysticks.has_key?(joystick_id)
        @joysticks[joystick_id].pressed(button)
      else
        @joysticks[joystick_id] = JoystickState.new
      end
    end

    def released(joystick_id : UInt32, button : UInt32)
      if @joysticks.has_key?(joystick_id)
        @joysticks[joystick_id].released(button)
      else
        @joysticks[joystick_id] = JoystickState.new
      end
    end

    def pressed?(joystick_id : UInt32, button : Button)
      @joysticks.has_key?(joystick_id) && @joysticks[joystick_id].pressed?(button)
    end

    def pressed?(button : Button)
      pressed?(0, button)
    end

    def pressed?(joystick_id : UInt32, buttons : Array(Button))
      buttons.any? { |button| pressed?(joystick_id, button) }
    end

    def pressed?(buttons : Array(Button))
      pressed?(0, buttons)
    end

    def any_pressed?(joystick_id = 0)
      @joysticks.has_key?(joystick_id) && @joysticks[joystick_id].any_pressed?
    end

    def just_pressed?(joystick_id : UInt32, button : Button)
      @joysticks.has_key?(joystick_id) && @joysticks[joystick_id].just_pressed?(button)
    end

    def just_pressed?(button : Button)
      just_pressed?(0, button)
    end

    def just_pressed?(joystick_id : UInt32, buttons : Array(Button))
      buttons.any? { |button| just_pressed?(joystick_id, button) }
    end

    def just_pressed?(buttons : Array(Button))
      just_pressed?(0, buttons)
    end

    def any_just_pressed?(joystick_id = 0)
      @joysticks.has_key?(joystick_id) && @joysticks[joystick_id].any_just_pressed?
    end
  end

  class JoystickState
    def initialize
      @buttons = Hash(UInt32, ButtonState).new
    end

    def reset
      @buttons.each do |(button, state)|
        state.seen unless state.seen?
      end
    end

    def pressed(button : UInt32)
      if @buttons.has_key?(button)
        @buttons[button].pressed
      else
        @buttons[button] = ButtonState.new(pressed: true)
      end
    end

    def released(button : UInt32)
      if @buttons.has_key?(button)
        @buttons[button].released
      else
        @buttons[button] = ButtonState.new(pressed: false)
      end
    end

    def pressed?(button : Joysticks::Button)
      @buttons.has_key?(button.value.to_u32) && @buttons[button.value.to_u32].pressed?
    end

    def pressed?(buttons : Array(Joysticks::Button))
      buttons.any? { |button| pressed?(button) }
    end

    def any_pressed?
      @buttons.any? do |(button, state)|
        state.pressed?
      end
    end

    def just_pressed?(button : Joysticks::Button)
      @buttons.has_key?(button.value.to_u32) && @buttons[button.value.to_u32].just_pressed?
    end

    def just_pressed?(buttons : Array(Joysticks::Button))
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
