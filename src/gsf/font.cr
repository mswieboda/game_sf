module GSF
  class Font

    EmptyString = ""

    def self.default
      @@font_default ||= SF::Font.from_file(default_file)
    end

    def self.default_file
      EmptyString
    end
  end
end
