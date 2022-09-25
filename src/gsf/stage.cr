module GSF
  abstract class Stage
    getter keys
    getter scene : Scene
    getter? exit

    def initialize
      @keys = Keys.new
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
      when SF::Event::KeyPressed
        keys.pressed(event.code)
      when SF::Event::KeyReleased
        keys.released(event.code)
      end
    end

    def update(frame_time)
      check_scenes
      scene.update(frame_time, keys)
      keys.reset
    end

    def draw(window : SF::RenderWindow)
      scene.draw(window)
    end
  end
end
