module GSF
  class Animation
    getter width
    getter height
    getter frame
    getter fps_factor
    getter? loops
    getter sprites
    getter? paused

    def initialize(fps_factor = 60, loops = true)
      @width = 0
      @height = 0
      @frame = 0
      @sprites = [] of SF::Sprite

      @fps_factor = fps_factor
      @loops = loops
      @paused = false
    end

    def add(filename : String, x, y, width, height, color : SF::Color? = nil, rotation = 0, flip_horizontal = false, flip_vertical = false, smooth = false, repeated = false)
      texture = SF::Texture.from_file(filename, SF::IntRect.new(x, y, width, height))
      texture.smooth = smooth
      texture.repeated = repeated

      sprite = SF::Sprite.new(texture)
      sprite.origin = texture.size / 2.0
      sprite.color = color ? color : SF::Color::White
      sprite.rotation = rotation if rotation != 0

      if flip_horizontal || flip_vertical
        sh = flip_horizontal ? -1 : 1
        sv = flip_vertical ? -1 : 1

        sprite.scale = {sh, sv}
      end

      # sprite.scale(Screen.scaling_factor, Screen.scaling_factor)

      sprites << sprite

      @height = height if height > @height
      @width = width if width > width
    end

    def restart
      @paused = false
      @frame = 0
    end

    def done?
      frame >= total_frames
    end

    def pause
      @paused = true
    end

    def display_frame
      (frame / fps_factor).to_i
    end

    def total_frames
      (sprites.size * fps_factor).to_i - 1
    end

    def update(_frame_time)
      return if paused?

      restart if loops? && done?

      @frame += 1 if frame < total_frames
    end

    def draw(window, x, y, flip_horizontal = false, flip_vertical = false, color : SF::Color? = nil, rotation = 0)
      if sprite = sprites[display_frame]
        sprite.position = {x, y}
        sprite.color = color if color
        sprite.rotation = rotation if rotation != 0

        if flip_horizontal || flip_vertical
          sh = flip_horizontal ? -1 : 1
          sv = flip_vertical ? -1 : 1

          sprite.scale = {sh, sv}
        end

        window.draw(sprite)
      else
        raise "> #{self.class.name}#draw !sprite"
      end
    end

    def global_bounds
      if sprite = sprites[display_frame]
        sprite.global_bounds
      else
        SF::FloatRect.new
      end
    end
  end
end
