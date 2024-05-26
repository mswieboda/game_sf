module GSF
  # NOTE: buttons and axes mapped from Xbox 360 controller
  #       not sure if these are standardized across different controllers
  class Joysticks
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

    alias Axis = SF::Joystick::Axis

    LeftStickX = Axis::X
    LeftStickY = Axis::Y
    DPadX = Axis::PovX
    DPadY = Axis::PovY
    RightStickX = Axis::U
    RightStickY = Axis::V
    # NOTE: Axis::Z is a combination of Left and Right Triggers, they cancel each other out
    Trigger = Axis::Z
    LeftTrigger = Axis::Z
    RightTrigger = Axis::Z

    AxisThreshold = 10

    @joysticks : Hash(UInt32, JoystickState)

    def initialize
      @joysticks = Hash(UInt32, JoystickState).new
    end

    def reset
      @joysticks.each do |(id, state)|
        state.reset
      end
    end

    def connect(id : UInt32)
      unless @joysticks.has_key?(id)
        @joysticks[id] = JoystickState.new
      end
    end

    def disconnect(id : UInt32)
      @joysticks.delete(id)
    end

    def connected?(id : UInt32)
      @joysticks.has_key?(id)
    end

    def pressed(id : UInt32, button : UInt32)
      unless connected?(id)
        @joysticks[id] = JoystickState.new
      end

      @joysticks[id].pressed(button)
    end

    def released(id : UInt32, button : UInt32)
      unless connected?(id)
        @joysticks[id] = JoystickState.new
      end

      @joysticks[id].released(button)
    end

    def axis_moved(id : UInt32, axis : Axis, position : Float32)
      unless connected?(id)
        @joysticks[id] = JoystickState.new
      end

      @joysticks[id].axis_moved(axis, position)
    end

    def pressed?(id : UInt32, button : Button)
      connected?(id) && @joysticks[id].pressed?(button)
    end

    def pressed?(button : Button)
      pressed?(0, button)
    end

    def pressed?(id : UInt32, buttons : Array(Button))
      buttons.any? { |button| pressed?(id, button) }
    end

    def pressed?(buttons : Array(Button))
      pressed?(0, buttons)
    end

    def any_pressed?(id = 0)
      connected?(id) && @joysticks[id].any_pressed?
    end

    def just_pressed?(id : UInt32, button : Button)
      connected?(id) && @joysticks[id].just_pressed?(button)
    end

    def just_pressed?(button : Button)
      just_pressed?(0, button)
    end

    def just_pressed?(id : UInt32, buttons : Array(Button))
      buttons.any? { |button| just_pressed?(id, button) }
    end

    def just_pressed?(buttons : Array(Button))
      just_pressed?(0, buttons)
    end

    def any_just_pressed?(id = 0)
      connected?(id) && @joysticks[id].any_just_pressed?
    end

    def axis_position(id : UInt32, axis : Axis)
      if connected?(id)
        @joysticks[id].axis_position(axis)
      else
        0_f32
      end
    end

    def axis_position(axis : Axis)
      axis_position(0, axis)
    end

    def axis_moved?(id : UInt32, axis : Axis, amount : Number)
      return false unless connected?(id)

      position = @joysticks[id].axis_position(axis)

      if amount > 0
        position > amount
      elsif amount < 0
        position < amount
      else
        position != amount
      end
    end

    def axis_moved?(axis : Axis, amount : Number)
      axis_moved?(0, axis, amount)
    end

    Util.stick_directions(["LeftStick", "DPad", "RightStick"])
  end

  class JoystickState
    def initialize
      @buttons = Hash(UInt32, ButtonState).new
      @axes = Hash(Joysticks::Axis, Float32).new
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

    def axis_moved(axis : Joysticks::Axis, position : Float32)
      @axes[axis] = position
    end

    def axis_position(axis : Joysticks::Axis)
      if @axes.has_key?(axis)
        @axes[axis]
      else
        0_f32
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
