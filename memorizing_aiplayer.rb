require_relative 'aiplayer.rb'

class MemorizingAiPlayer < AiPlayer

  def self.parse(file_name)
    ensure_directory(file_name)
    File.open(file_name, 'a') { |file| file }
    make_dictionary(file_name)
  end

  def self.make_dictionary(file_name)
    dict = {}
    File.readlines(file_name).map(&:chomp).each do |line|
      parse_line(dict, line)
    end
    dict
  end

  def self.parse_line(dict, line)
      dict[line] = true
  end

  def self.dump_to(dictionary_arr, file_name)
    ensure_directory(file_name)
    File.open(file_name, 'w') do |file|
      file.write(dictionary_arr.join("\n") + "\n")
    end
  end

  def self.ensure_directory(file_name)
    directory = File.dirname(file_name)
    Dir.mkdir(directory) unless (File.directory?(directory))
  end

  def initialize(name = "Computer")
    super(name)
    set_vars
  end

  def dump_memory(file_name = "#{@name}#{Time.now}")
    file_name = file_name.downcase.scan(/\w+/).join("")
    MemorizingAiPlayer.dump_to @_dictionary.sort, "#{DIR}/#{file_name}.dict.txt"
  end

  DIR = "memorizing"

  private

    def set_vars
      @color = :light_blue
      @memory_file = "#{DIR}/current.dict.txt"
      @_dictionary = MemorizingAiPlayer.parse(@memory_file)
    end

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
