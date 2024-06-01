module GSF
  class StyledText < SF::Text
    @sections : Array(StyledTextSection)
    @raw_text : String

    FontSize = 10

    # sample text that is formatted:
    # "hi this is a [s=ibu]test[/s], head to [s=b fc=#ff0000]Baron Cave[/s]
    # to find the [s=b]lost relic[/s] somewhere in
    # the [s fc=#0000ff oc=#00ff00]3rd basement level[/s]."

    def initialize(@raw_text = "", font = SF::Font.new, font_size = FontSize)
      super(@raw_text, font, font_size)

      @sections = [] of StyledTextSection

      parse_text
    end

    def parse_text
      # find matching opening and closing tags [s][/s]
      # cannot be nested, use individual wrapped styles instead
      # options:
      # [s=b]: SF::TextStyle::Bold
      # [s=i]: SF::TextStyle::Italic
      # [s=u]: SF::TextStyle::Underlined
      # [s=s]: SF::TextStyle::StrikeThrough
      # can be combined, in any order like
      # [s=iub]: bold, italic underlined
      # for colors there is fc, oc:
      # [s fc=#ff00ffcc]: fill color, in hex #rrggbb or #rrggbbaa format
      # [s oc=#0000ff]: outline color in hex #rrggbb or #rrggbbaa format
      # can be combined with s, for style and colors:
      # [s=bi fc=#ff00ff oc=#00ff00cc] in which case it should end in `[/s]`

      offset_index = 0

      while style_start = @raw_text.index("[s", offset_index)
        # NOTE: for now, only check for s=, ignoring "fc" and "oc" colors
        if style_type_start = @raw_text.index(/\=[bius]/, style_start)
          # skips the = sign
          style_type_start += 1

          if style_type_end = @raw_text.index(/[\]\W]/, style_type_start)
            # skips either the space to attributes, or the ]
            style_type_end -= 1
            style_types = @raw_text[style_type_start..style_type_end]

            if style_type_end = @raw_text.index(']', style_type_end)
              text_start = style_type_end + 1

              if style_end = @raw_text.index("[/s]", text_start)
                # NOTE: ignoring "fc" and "oc" colors for now
                styles = self.class.get_styles(style_types)
                text = @raw_text[text_start...style_end]

                # TODO: for now make the unstyled text be Style::Regular, but should unpack self.style to styles array
                @sections << StyledTextSection.new(@raw_text[offset_index...style_start], [SF::Text::Style::Regular], self.fill_color, self.outline_color)
                @sections << StyledTextSection.new(text, styles, self.fill_color, self.outline_color)

                offset_index = style_end + 4
              else
                offset_index += 1
              end
            else
              offset_index += 1
            end
          else
            offset_index += 1
          end
        else
          offset_index += 1
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
