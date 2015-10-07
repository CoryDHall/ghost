require_relative 'aiplayer.rb'

class MemorizingAiPlayer < AiPlayer

  def self.parse_dictionary(file)
    File.readlines(file).map(&:chomp)
  end

  def initialize(name = "Computer")
    super(name)
    @color = :light_blue
    @memory_file = "memorizing/dict.txt"
    @_dumb_dictionary = MemorizingAiPlayer.parse_dictionary(@memory_file)
  end

  private

    def think
      memorize @current_frag[0...-1]
      last_messages.last.downcase.match(/enter/) do
        @current_possibles = @current_possibles.shuffle
        ready = false
        item_on = 0
        until ready || item_on >= @current_possibles.length
          new_guess = @current_possibles.last
          ready = @_dumb_dictionary.any? { |e| e == (@current_frag + new_guess) }
          @current_possibles.pop() if ready
          item_on += 1
        end
        new_guess ||= @current_possibles.shuffle.pop()
        $stdin.puts new_guess
      end
    end

    def memorize(word)
      if @_dumb_dictionary.none? { |e| e[word] }
        @_dumb_dictionary << word
        File.open(@memory_file, 'a+') do |file|
          file.write("#{word}\n")
        end
      end
    end

    def last_lines_chunk
      last_messages.join("\n")
    end

    def last_messages
      lines = $stdout.string.split("\n")[line_counter..-1]
      line_counter = lines.count - 1
      lines
    end

end
