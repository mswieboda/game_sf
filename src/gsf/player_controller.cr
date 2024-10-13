require "./movable"

module GSF
  module PlayerController
    alias Key = SF::Keyboard::Key

    getter? dead # = false
    getter death_timer : Timer # = Timer.new(DeathAnimationDuration)

    DeathAnimationDuration = 300.milliseconds

    def initialize_player_controller
      @dead = false
      @death_timer = Timer.new(death_animation_duration)
    end

    def reset_player_controller
      @dead = false
      @death_timer.stop
    end

    # BEGIN - constant methods
    # these methods can be easily overriden to change
    # constant-like values in the including class

    # TODO: make this extendable, and used in the Player constructor to set above @death_timer
    def death_animation_duration
      DeathAnimationDuration
    end

    def keys_left : Key | Array(Key)
      Keys::A
    end

    def joystick_left?(joysticks : Joysticks) : Bool
      joysticks.left_stick_moved_left? || joysticks.d_pad_moved_left?
    end

    def keys_right : Key | Array(Key)
      Keys::D
    end

    def joystick_right?(joysticks : Joysticks) : Bool
      joysticks.left_stick_moved_right? || joysticks.d_pad_moved_right?
    end

    def keys_up : Key | Array(Key)
      Keys::W
    end

    def joystick_up?(joysticks : Joysticks) : Bool
      joysticks.left_stick_moved_up? || joysticks.d_pad_moved_up?
    end

    def keys_down : Key | Array(Key)
      Keys::S
    end

    def joystick_down?(joysticks : Joysticks) : Bool
      joysticks.left_stick_moved_down? || joysticks.d_pad_moved_down?
    end

    # END - constant methods

    def movement_input(keys : Keys, joysticks : Joysticks) : Tuple(Int32, Int32)
      dx = movement_dx_input(keys, joysticks)
      dy = movement_dy_input(keys, joysticks)

      {dx, dy}
    end

    private def movement_dx_input(keys : Keys, joysticks : Joysticks)
      dx = 0

      return dx if dead?

      dx -= 1 if keys.pressed?(keys_left) || joystick_left?(joysticks)
      dx += 1 if keys.pressed?(keys_right) || joystick_right?(joysticks)

      dx
    end

    private def movement_dy_input(keys : Keys, joysticks : Joysticks)
      dy = 0

      return dy if dead?

      dy -= 1 if keys.pressed?(keys_up) || joystick_up?(joysticks)
      dy += 1 if keys.pressed?(keys_down) || joystick_down?(joysticks)

      dy
    end

    def die!
      death_timer.start unless dead?
      @dead = true
    end
  end
end
