module GSF
  class Screen
    @@view : SF::View = SF::View.new

    def self.width
      @@view.size.x
    end

    def self.height
      @@view.size.y
    end

    def self.init(window : SF::RenderWindow, width, height, target_height : UInt32? = nil)
      if t_height = target_height
        if height > t_height
          ratio = (height / t_height).ceil.to_i
          width = (width / ratio).to_i
          height = (height / ratio).to_i
        end
      end

      window.view = SF::View.new(SF.float_rect(0, 0, width, height))
      @@view = window.view
    end
  end
end
