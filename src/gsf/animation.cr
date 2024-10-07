module GSF
  class Animation
    getter frame : Int32
    getter? loops
    getter? paused

    @sprites : Array(SF::Sprite)
    @frame_durations_ms : Array(Int32) # in milliseconds
    @frame_time_ms : Int32 # in milliseconds

    def initialize(loops = true)
      @sprites = [] of SF::Sprite
      @frame_durations_ms = [] of Int32
      @frame = 0
      @frame_time_ms = 0
      @loops = loops
      @paused = false
    end

    def add(
      filename : String,
      x : Int32 = 0,
      y : Int32 = 0,
      width : Int32 = 1,
      height : Int32 = 1,
      duration_ms : Int32 = 125,
      color : SF::Color? = nil,
      rotation = 0,
      flip_horizontal = false,
      flip_vertical = false,
      smooth = false,
      repeated = false,
      scale = {1, 1}
    )
      texture = SF::Texture.from_file(filename, SF::IntRect.new(x, y, width, height))
      texture.smooth = smooth
      texture.repeated = repeated

      sprite = SF::Sprite.new(texture)
      sprite.origin = texture.size / 2.0
      sprite.color = color ? color : SF::Color::White
      sprite.rotation = rotation if rotation != 0
      sprite.scale = scale

      if flip_horizontal || flip_vertical
        sh = flip_horizontal ? -1 : 1
        sv = flip_vertical ? -1 : 1

        sprite.scale({sh, sv})
      end

      @sprites << sprite
      @frame_durations_ms << duration_ms
    end

    def play
      @paused = false
    end

    def restart
      @paused = false
      @frame_time_ms = 0
      @frame = 0
    end

    def done?
      frame >= @sprites.size - 1 && frame_done?
    end

    def frame_done?
      @frame_time_ms >= @frame_durations_ms[frame]
    end

    def pause
      @paused = true
    end

    def next_frame_info : Tuple(Int32, Int32)
      frame_time_remainder_ms = @frame_time_ms
      frame_index = @frame

      while frame_time_remainder_ms >= @frame_durations_ms[frame_index]
        frame_time_remainder_ms -= @frame_durations_ms[frame_index]

        if frame_index + 1 < @frame_durations_ms.size
          frame_index += 1
        elsif loops?
          frame_time_remainder_ms -= @frame_durations_ms[frame_index]
          frame_index = 0
        end
      end

      {frame_time_remainder_ms, frame_index}
    end

    def update(frame_time : Float32)
      # frame_time is in seconds, @frame_time_ms is in milliseconds
      @frame_time_ms += (frame_time * 1000).round.to_i unless done?

      return if paused?

      if frame_done?
        remainder, frame = next_frame_info
        @frame_time_ms = remainder
        @frame = frame
      end
    end

    def draw(window, x, y, flip_horizontal = false, flip_vertical = false, color : SF::Color? = nil, rotation = 0)
      if sprite = @sprites[frame]
        sprite.position = {x, y}
        sprite.color = color if color
        sprite.rotation = rotation
        sh = flip_horizontal && sprite.scale.x > 0 ? -1 : 1
        sv = flip_vertical && sprite.scale.y > 0 ? -1 : 1
        sprite.scale({sh, sv})

        window.draw(sprite)
      else
        raise "> #{self.class.name}#draw !@sprites[frame]"
      end
    end

    def global_bounds
      if sprite = sprites[frame]
        sprite.global_bounds
      else
        SF::FloatRect.new
      end
    end
  end
end
