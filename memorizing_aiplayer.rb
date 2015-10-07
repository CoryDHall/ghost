require_relative 'aiplayer.rb'

class MemorizingAiPlayer < AiPlayer

  def self.parse(file_name)
    File.open(file_name, 'a')
    lines = {}
    File.readlines(file_name).map(&:chomp).each do |line|
      lines[line] = true
    end
    lines
  end

  def self.dump_to(dictionary_arr, file_name)
    File.open(file_name, 'w') do |file|
      file.write(dictionary_arr.join("\n") + "\n")
    end
  end

  def initialize(name = "Computer")
    super(name)
    @color = :light_blue
    @memory_file = "memorizing/current.dict.txt"
    @_dictionary = MemorizingAiPlayer.parse(@memory_file)
  end

  def dump_memory(file_name = "#{@name}#{Time.now}")
    file_name = file_name.downcase.scan(/\w+/).join("")
    MemorizingAiPlayer.dump_to @_dictionary.sort, "memorizing/#{file_name}.dict.txt"
  end

  private

    def think
      memorize @current_frag
      last_messages.last.downcase.match(/enter/) do
        @current_possibles = @current_possibles.shuffle
        ready = false
        item_on = 0
        until ready || item_on >= @current_possibles.length
          new_guess = @current_possibles.last
          ready = remembers?(@current_frag + new_guess)
          @current_possibles.pop() if ready
          item_on += 1
        end
        new_guess ||= @current_possibles.shuffle.pop()
        $stdin.puts new_guess
      end
    end

    def memorize(word)
      unless @_dictionary[word]
        @_dictionary[word] = true
        add_to_memory word
        memorize word.chop
      end
    end

    def add_to_memory(word)
      File.open(@memory_file, 'a+') do |file|
        file.write("#{word}\n")
      end
    end

    def remembers?(word)
      !!@_dictionary[word]
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
