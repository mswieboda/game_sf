require "./message"

module GSF
  class Dialog
    alias Data = Hash(String, NamedTuple(message: String, choices: Array(Message::ChoiceData)))

    getter choice_selected : Message::ChoiceData?
    getter data : Data

    @message : Message

    def initialize(@data = Data.new, typing = true, animate = true)
      @message = message_class.new(
        typing: typing,
        animate: animate,
        choices: [] of Message::ChoiceData
      )
      @choice_selected = nil
    end

    delegate choice_selected, to: @message
    delegate show?, to: @message

    # NOTE: this can be overriden for a custom BottomCenteredMessage class
    def message_class
      BottomCenteredMessage
    end

    def hide_reset
      @choice_selected = nil
      @message.hide_reset
    end

    def show(key : String)
      @message.update_data(@data[key][:message], @data[key][:choices])
      @message.show
    end

    def update(keys : Keys)
      @choice_selected = nil if @choice_selected

      @message.update(keys)

      if choice = @message.choice_selected
        key = choice[:key]

        @message.reset_choice_selected

        if @data.has_key?(key)
          @message.update_data(@data[key][:message], @data[key][:choices])
        else
          @choice_selected = choice
          @message.next_page_or_hide
        end
      end
    end

    def draw(window : SF::RenderWindow)
      @message.draw(window)
    end
  end
end
