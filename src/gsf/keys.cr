module GSF
  class Keys
    alias Key = SF::Keyboard::Key

    Util.extract SF::Keyboard::Key

    def initialize
      @keys = Hash(Key, KeyState).new
    end

    def reset
      @keys.each do |(key, state)|
        state.seen unless state.seen?
      end
    end

    def pressed(key : Key)
      if @keys.has_key?(key)
        @keys[key].pressed
      else
        @keys[key] = KeyState.new(pressed: true)
      end
    end

    def released(key : Key)
      if @keys.has_key?(key)
        @keys[key].released
      else
        @keys[key] = KeyState.new(pressed: false)
      end
    end

    def pressed?(key : Key)
      @keys.has_key?(key) && @keys[key].pressed?
    end

    def pressed?(keys : Array(Key))
      keys.any? { |key| pressed?(key) }
    end

    def any_pressed?
      @keys.any? do |(key, state)|
        state.pressed?
      end
    end

    def just_pressed?(key : Key)
      @keys.has_key?(key) && @keys[key].just_pressed?
    end

    def just_pressed?(keys : Array(Key))
      keys.any? { |key| just_pressed?(key) }
    end

    def any_just_pressed?
      @keys.any do |(key, state)|
        state.just_pressed?
      end
    end
  end

  class KeyState
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
