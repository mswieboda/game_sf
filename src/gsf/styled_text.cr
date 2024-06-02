module GSF
  class StyledText < SF::Text
    @sections : Array(StyledTextSection)
    @raw_text : String

    FontSize = 10

    # sample text that is formatted:
    # "hi this is a [s=ibu]test[/s], head to [s=b fc=#ff0000]Baron Cave[/s]
    # to find the [s=b]lost relic[/s] somewhere in
    # the [s= fc=#0000ff oc=#00ff00]3rd basement level[/s]."

    def initialize(@raw_text = "", font = SF::Font.new, font_size = FontSize)
      super(@raw_text, font, font_size)

      @sections = [] of StyledTextSection

      parse_text
    end

    def parse_text
      # NOTE: cannot be nested, use individual wrapped styles instead
      # options:
      # [s=b]: SF::TextStyle::Bold
      # [s=i]: SF::TextStyle::Italic
      # [s=u]: SF::TextStyle::Underlined
      # [s=s]: SF::TextStyle::StrikeThrough
      # styles can be combined, in any order:
      # [s=iub]: bold, italic underlined

      # for colors there is fc, oc for fill/outline color
      # but `[s=` is required however no style needs to be added:
      # [s= fc=#ff00ffcc]: fill color, in hex #rgb or #rrggbb or #rrggbbaa format
      # [s= oc=#0000ff]: outline color in hex #rgb or #rrggbb or #rrggbbaa format
      # can be combined fully with s= styles, for styles and colors:
      # [s=bi fc=#ff00ff oc=#00ff00cc]

      offset_index = 0

      while style_start = @raw_text.index("[s=", offset_index)
        if style_end = @raw_text.index(']', style_start)
          # skips ]
          text_start = style_end + 1

          # check for style closing
          if text_end = @raw_text.index("[/s]", text_start)
            style_types = ""
            fill_color = self.fill_color
            outline_color = self.outline_color
            text = @raw_text[text_start...text_end]

            # check styles
            if style_type_start = @raw_text[0..style_end].index(/\=[bius]+/, style_start)
              # skips =
              style_type_start += 1

              if style_type_end = @raw_text[0..style_end].index(/[\]\W]/, style_type_start)
                style_types = @raw_text[style_type_start...style_type_end]
              end
            end

            styles = self.class.get_styles(style_types)

            # check colors
            color_style_start = style_start

            while color_attribute_start = @raw_text[0..style_end].index(/[fo]c\=#/, color_style_start)
              # skips the [fo]c=#
              color_hex_start = color_attribute_start + 4

              if color_hex_end = @raw_text.index(/[\W\]]/, color_hex_start)
                color_hex = @raw_text[color_hex_start...color_hex_end]

                if @raw_text[color_attribute_start] == 'f'
                  fill_color = self.class.hex_to_color(color_hex)
                elsif @raw_text[color_attribute_start] == 'o'
                  outline_color = self.class.hex_to_color(color_hex)
                end

                color_style_start = color_hex_end
              else
                break
              end
            end

            # TODO: for now make the unstyled text be Style::Regular, but should unpack self.style to styles array
            @sections << StyledTextSection.new(@raw_text[offset_index...style_start], [SF::Text::Style::Regular], self.fill_color, self.outline_color)
            @sections << StyledTextSection.new(text, styles, fill_color, outline_color)

            # skips the [/s]
            offset_index = text_end + 4
          else
            break
          end
        else
          break
        end
      end

      # put the remainder into a section, unless there are no sections
      if @sections.any?
        @sections << StyledTextSection.new(@raw_text[offset_index..-1], [SF::Text::Style::Regular], self.fill_color, self.outline_color)
      end
    end

    def self.get_styles(style_types : String) : Array(SF::Text::Style)
      if style_types.empty?
        return [SF::Text::Style::Regular]
      end

      style_types.chars.map do |style_type|
        if style_type == 'b'
          SF::Text::Style::Bold
        elsif style_type == 'i'
          SF::Text::Style::Italic
        elsif style_type == 'u'
          SF::Text::Style::Underlined
        elsif style_type == 's'
          SF::Text::Style::StrikeThrough
        else
          SF::Text::Style::Regular
        end
      end
    end

    def self.hex_to_color(color_hex : String) : SF::Color
      if color_hex.starts_with?('#')
        color_hex = color_hex[1..-1]
      end

      if color_hex.size == 3
        color_hex = color_hex.chars.map do |char|
          "#{char}#{char}"
        end.join
      end

      r = color_hex[0..1].to_i(16)
      g = color_hex[2..3].to_i(16)
      b = color_hex[4..5].to_i(16)
      a = color_hex.size < 8 ? 255 : color_hex[6..7].to_i(16)

      SF::Color.new(r, g, b, a)
    end

    def draw(target : SF::RenderTarget, states : SF::RenderStates)
      if @sections.empty?
        super(target, states)
      else
        orig_fill_color = self.fill_color
        orig_outline_color = self.outline_color
        orig_position = self.position
        orig_string = self.string
        # TODO: need to unpack self.style from UInt32 to Array(SF::Text::Style)
        # orig_styles = self.class.get_styles(self.style)
        orig_styles = [] of SF::Text::Style

        @sections.each_with_index do |section, index|
          # changing self via string, position, style, colors etc
          self.string = section.text
          self.fill_color = section.fill_color
          self.outline_color = section.outline_color

          total_style = SF::Text::Style::Regular

          section.styles.each do |style|
            total_style |= style
          end

          self.style = total_style

          # draw
          super(target, states)

          # move position for next section
          self.move(global_bounds.width, 0)
        end

        # put everything back
        self.fill_color = orig_fill_color
        self.outline_color = orig_outline_color
        self.position = orig_position
        self.string = orig_string

        total_style = SF::Text::Style::Regular

        orig_styles.each do |style|
          total_style |= style
        end

        self.style = total_style
      end
    end
  end

  class StyledTextSection
    getter text : String
    getter styles : Array(SF::Text::Style)
    getter fill_color : SF::Color
    getter outline_color : SF::Color

    def initialize(@text, @styles, @fill_color, @outline_color)
    end
  end
end
