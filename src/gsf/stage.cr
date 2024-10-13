module GSF
  abstract class Stage
    getter keys
    getter mouse
    getter joysticks
    getter scene : Scene
    getter? exit

    def initialize
      @keys = Keys.new
      @mouse = Mouse.new
      @joysticks = Joysticks.new
      @scene = SceneEmpty.new
      @exit = false
    end

    # check when to switch scenes using `switch(scene : Scene)`
    abstract def check_scenes

    def switch(scene : Scene)
      @scene.reset

      Screen.reset_view

      @scene = scene

      @scene.init
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
        joysticks.pressed(event.joystick_id, event.button)
      when SF::Event::JoystickButtonReleased # : joystick_id, button
        joysticks.released(event.joystick_id, event.button)
      when SF::Event::JoystickMoved # : joystick_id, axis, position
        joysticks.axis_moved(event.joystick_id, event.axis, event.position)
      when SF::Event::JoystickConnected # : joystick_id
        joysticks.connect(event.joystick_id)
      when SF::Event::JoystickDisconnected # : joystick_id
        joysticks.disconnect(event.joystick_id)
      end
    end

    def update(frame_time : Float32)
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
