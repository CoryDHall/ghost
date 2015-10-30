require_relative 'memorizing_aiplayer.rb'
require_relative 'node.rb'

class Ai::BetterMemorizer < Ai::Memorizer

  def self.make_dictionary(file_name)
    Node.from_yaml File.read(file_name)
  end

  def self.dump_to(dictionary, file_name)
    ensure_directory(file_name)
    File.open(file_name, 'w') do |file|
      file.write(dictionary.to_yaml)
    end
  end

  def initialize(name = "Computer")
    super(name)
    set_vars
  end

  def dump_memory(file_name = "#{@name}#{Time.now}")
    file_name = file_name.downcase.scan(/\w+/).join("")

    new_memory = Ai::BetterMemorizer.dictionary_to_node @_dictionary

    Ai::BetterMemorizer.dump_to new_memory, "#{DIR}/#{file_name}.dict.yml"
  end

  def commit_memory
    dump_memory "current"
  end

  DIR = "memorizing_2"

  private

    def set_vars
      @color = :light_blue
      @memory_file = "#{DIR}/current.dict.yml"
      @memory = Ai::BetterMemorizer.parse(@memory_file)
      @_dictionary = Ai::BetterMemorizer.to_dictionary(@memory)
    end

    def think
      memorize @current_frag
      last_messages.last.downcase.match(/enter/) do
        @current_possibles = @current_possibles.shuffle
        ready = false
        item_on = 0
        until ready || item_on >= @current_possibles.length
          new_guess = @current_possibles.last
          ready = remembers?(new_guess)
          @current_possibles.pop() if ready
          item_on += 1
        end
        new_guess ||= @current_possibles.shuffle.pop()
        $stdin.puts new_guess
      end
    end

    def memorize(word)
      mem_str = memory_str word
      @_current_node = @_dictionary.search mem_str
      unless @_current_node
        @_current_node = add_to_dictionary mem_str
      end
    end

    def memory_str(word)
      word.split ''
    end

    def add_to_dictionary(mem_str)
      top_node = @_dictionary
      mem_str.each do |char|
        top_node = top_node.find_or_create char
      end
      top_node
    end

    def remembers?(word)
      @_current_node.has_child? word
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
