require "./message"

module GSF
  class Dialog
    getter choice_selected : String?

    @message : Message

    def initialize(message = "", typing = true, animate = true, choices = [] of String)
      @message = message_class.new(
        message: message,
        typing: typing,
        animate: animate,
        choices: choices
      )
      @choice_selected = nil
    end

    delegate choice_selected, to: @message
    delegate show?, to: @message
    delegate show, to: @message

    def message_class
      BottomCenteredMessage
    end

    def hide_reset
      @choice_selected = nil
      @message.hide_reset
    end

    def update(keys : Keys)
      @choice_selected = nil if @choice_selected

      @message.update(keys)

      if choice = @message.choice_selected
        @choice_selected = choice
        @message.next_page_or_hide
      end
    end

    def draw(window : SF::RenderWindow)
      @message.draw(window)
    end
  end
end
