module GSF
  abstract class Stage
    getter window
    getter keys
    getter mouse
    getter joysticks
    getter scene : Scene
    getter? exit

    def initialize(window : SF::Window)
      @window = window
      @keys = Keys.new
      @mouse = Mouse.new
      @joysticks = Joysticks.new
      @scene = SceneEmpty.new
      @exit = false
    end

    # check when to switch scenes using `switch(nextScene : Scene)`
    abstract def check_scenes

    def switch(nextScene : Scene)
      scene.reset

      @scene = nextScene

      scene.init
    end

    # called from GSF::Game, used to set things like keys, mouse, etc from events
    def event(event)
      case event
      when SF::Event::MouseMoved
        mouse.moved(event)
      when SF::Event::KeyPressed
        keys.pressed(event.code)
      when SF::Event::KeyReleased
        keys.released(event.code)
      when SF::Event::MouseButtonPressed
        mouse.pressed(event.button)
      when SF::Event::MouseButtonReleased
        mouse.released(event.button)
      when SF::Event::JoystickButtonPressed # : joystick_id, button
        puts ">>> JoystickButtonPressed #{event.joystick_id} #{event.button}"
        joysticks.pressed(event.joystick_id, event.button)
      when SF::Event::JoystickButtonReleased # : joystick_id, button
        puts ">>> JoystickButtonReleased #{event.joystick_id} #{event.button}"
        joysticks.released(event.joystick_id, event.button)
      when SF::Event::JoystickMoved # : joystick_id, axis, position
      when SF::Event::JoystickConnected # : joystick_id
        puts ">>> JoystickConnected #{event.joystick_id}"
      when SF::Event::JoystickDisconnected # : joystick_id
        puts ">>> JoystickDisconnected #{event.joystick_id}"
      end
    end

    def update(frame_time)
      check_scenes
      scene.update(frame_time, keys, mouse, joysticks)
      keys.reset
      mouse.reset
      joysticks.reset
    end

    def draw(window : SF::RenderWindow)
      scene.draw(window)
    end
  end
end
