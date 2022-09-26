module GSF
  abstract class Stage
    getter keys
    getter mouse
    getter scene : Scene
    getter? exit

    def initialize
      @keys = Keys.new
      @mouse = Mouse.new
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
      end
    end

    def update(frame_time)
      check_scenes
      scene.update(frame_time, keys, mouse)
      keys.reset
      mouse.reset
    end

    def draw(window : SF::RenderWindow)
      scene.draw(window)
    end
  end
end
