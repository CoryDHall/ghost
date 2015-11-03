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

  def self.to_dictionary(memory_node)
    dict = {}
    words = node_to_frags(memory_node)
    words.each do |word|
      dict[word] = true
    end
    dict
  end

  def self.node_to_frags(node, frag="")
    output = []
    node.each_child do |letter, child|
      new_frag = frag + letter
      output.concat([new_frag])
      output.concat(node_to_frags(child, new_frag))
    end
    output
  end

  def self.dictionary_to_node(dict)
    node = Node.new ""
    dict.each_key do |fragment|
      top_node = node
      fragment.each_char do |chr|
        top_node = top_node.find_or_create chr
      end
    end
    node
  end

  def self.clear_dictionary!
    node = dictionary_to_node({})
    dump_to node, "#{DIR}/current.dict.yml"
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
          ready = remembers?(@current_frag + new_guess)
          @current_possibles.pop() if ready
          item_on += 1
        end
        new_guess ||= @current_possibles.shuffle.pop()
        $stdin.puts new_guess
      end
    end

    def memorize(word)
      unless remembers? word
        add_to_dictionary word
        memorize word.chop
      end
    end

    def add_to_dictionary(word)
      @_dictionary[word] = true
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
