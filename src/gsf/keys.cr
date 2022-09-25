module GSF
  class Keys
    private module Util
      # Copy all constants from the namespace into the current namespace
      macro extract(from)
        {% for c in from.resolve.constants %}
          # :nodoc:
          {{c}} = {{from}}::{{c}}{% if c.id.ends_with? "Count" %}.value{% end %}
        {% end %}
      end
    end

    alias Key = SF::Keyboard::Key

    Util.extract Key

    def initialize
      @keys = Hash(SF::Keyboard::Key, KeyState).new
    end

    def reset
      @keys.each do |(keycode, keystate)|
        keystate.seen unless keystate.seen?
      end
    end

    def pressed(keycode : SF::Keyboard::Key)
      if @keys.has_key?(keycode)
        @keys[keycode].pressed
      else
        @keys[keycode] = KeyState.new(pressed: true)
      end
    end

    def released(keycode : SF::Keyboard::Key)
      if @keys.has_key?(keycode)
        @keys[keycode].released
      else
        @keys[keycode] = KeyState.new(pressed: false)
      end
    end

    def pressed?(keycode : SF::Keyboard::Key)
      @keys.has_key?(keycode) && @keys[keycode].pressed?
    end

    def pressed?(keycodes : Array(SF::Keyboard::Key))
      keycodes.any? { |keycode| pressed?(keycode) }
    end

    def any_pressed?
      @keys.any? do |(keycode, keystate)|
        keystate.pressed?
      end
    end

    def just_pressed?(keycode : SF::Keyboard::Key)
      @keys.has_key?(keycode) && @keys[keycode].just_pressed?
    end

    def just_pressed?(keycodes : Array(SF::Keyboard::Key))
      keycodes.any? { |keycode| just_pressed?(keycode) }
    end

    def any_just_pressed?
      @keys.any do |(keycode, keystate)|
        keystate.just_pressed?
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
