require_relative 'aiplayer.rb'

class MemorizingAiPlayer < AiPlayer

  def initialize(name = "Computer")
    super(name)
    @color = :light_blue
    @line_counter = 0
    @memory_file = "memorizing/dict.txt"
    @_dumb_dictionary = []
    @personal_dictionary = MemorizingAiPlayer.parse_dictionary(@memory_file, @_dumb_dictionary)
  end

  def self.parse_dictionary(file, fill_dumb)
    word_array = File.readlines(file).map(&:chomp)
    fill_dumb = fill_dumb.concat word_array if fill_dumb
    word_hash = {}
    word_array.each do |word|
      merge word_hash, word
    end
    word_hash
  end

  def self.hashify(word)
    return {} if word.nil? || word.empty?
    { word[0] => hashify(word[1..-1]) }
  end

  def self.merge(hash, word)
    if hash[word[0]]
      hash.merge(merge(hash[word[0]], word[1..-1]))
    else
      hash[word[0]] = hashify(word[1..-1])
    end
  rescue
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

  def set_streams
    # @streams[1].print $stdin.gets
    # @streams[1].print $stdout.gets
    super
  end

  private

    attr_accessor :line_counter

    def think
      if @_dumb_dictionary.none? { |e| e[@current_frag[0...-1]] }
        MemorizingAiPlayer.merge @personal_dictionary, @current_frag
        @_dumb_dictionary << @current_frag[0...-1]
        File.open(@memory_file, 'a+') do |file|
          file.write("#{@current_frag[0...-1]}\n")
        end
      end
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

    def last_lines_chunk
      last_messages.join("\n")
    end

    def last_messages
      lines = $stdout.string.split("\n")[line_counter..-1]
      line_counter = lines.count - 1
      lines
    end

end
