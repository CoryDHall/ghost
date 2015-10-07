require_relative 'player.rb'

class AiPlayer < Player

  def initialize(name = "Computer")
    super(name, :light_red, [StringIO.open(" \n"), StringIO.open(" \n")])
    @line_counter = 0
  end

  def guess(fragment)
    set_streams
    @current_frag = fragment
    @current_possibles = ("a".."z").to_a
    prompt
    think
    get_response
  end

  def get_response
    $stdin.string.split("\n").last
  end

  private

    attr_accessor :line_counter

    def think
      last_messages.last.downcase.match(/enter/) do
        $stdin.puts @current_possibles.shuffle.pop
      end
    end

    def last_messages
      lines = $stdout.string.split("\n") #[line_counter..-1]
      line_counter = lines.count - 1
      lines
    end

end
