{% if flag?(:win32) %}
  require "../../crsfml/src/crsfml"
  require "../../crsfml/src/audio"
{% else %}
  require "crsfml"
  require "crsfml/audio"
{% end %}

require "./gsf/*"

module GSF
  VERSION = "0.1.0"
end
