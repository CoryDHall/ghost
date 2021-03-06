require_relative 'memorizing_aiplayer.rb'

class Ai::Bayesian < Ai::Memorizer

  def dump_memory(file_name = "#{@name}#{Time.now}")
    file_name = file_name.downcase.scan(/\w+/).join("")
    Ai::Bayesian.dump_to dict_string_arr, "#{DIR}/#{file_name}.dict.txt"
  end

  def dict_string_arr
    output = []
    @_dictionary.each do |letter, data|
      output << "#{letter}\t#{data.values.map(&:to_i).join("\t")}"
    end
    output
  end

  def self.clear_dictionary!
    dictionary_arr = []
    ("a".."z").each do |letter|
      dictionary_arr << "#{letter}\t0\t0"
    end
    dump_to dictionary_arr, "#{DIR}/current.dict.txt"
  end

  def self.parse_line(dict, line)
    letter, valids, losses = line.scan(/[a-z]|\d+/)
    dict[letter] ||= Hash.new do |h, k|
      h[k] = 0
    end
    dict[letter][:valids] = valids.to_f
    dict[letter][:losses] = losses.to_f
  end

  DIR = "bayesian"

  def lose_round
    super
    @_dictionary[@last_guess][:losses] += 1
    @total_losses += 1
    save_memory
  end

  private

    attr_accessor :last_guess

    def set_vars
      @color = :light_green
      @memory_file = "#{DIR}/current.dict.txt"
      @_dictionary = Ai::Bayesian.parse(@memory_file)
      set_total
      @invalids = {}
      @old_frag = "*"
      @last_guess = ""
    end

    def set_total
      @total_valids = 0.0
      @total_losses = 0.0
      @_dictionary.values.each do |data|
        @total_valids += data[:valids]
        @total_losses += data[:losses]
      end
    end

    def think
      last_messages.last.downcase.match(/enter/) do
        @last_guess = choose_letter
        @_dictionary[@last_guess][:valids] += 1
        @total_valids += 1
        save_memory

        $stdin.puts @last_guess
      end
    end

    def chance_valid(letter)
      v = @_dictionary[letter][:valids]
      v == 0 ? 1.0 : v / @total_valids
    end

    def chance_loss(letter)
      v = @_dictionary[letter][:valids]
      v == 0 ? 0.0 : @_dictionary[letter][:losses] / v
    end

    def losses_to_valids
      @total_losses == 0 ? 1.0 : @total_losses / @total_valids
    end

    def choose_letter
      if played_valid?
        @old_frag = "#{@current_frag}"
        @invalids = @invalids.clear
      else
        @_dictionary[@last_guess][:valids] -= 1
        @total_valids -= 1
        @invalids[@last_guess] = true
      end
      find_best
    end

    def find_best
      highest_success_rate = 0
      choice = nil
      @_dictionary.each_key do |letter|
        success_rate = (1 - chance_loss(letter)) / (losses_to_valids / chance_valid(letter))
        if success_rate > highest_success_rate && @invalids[letter].nil?
          highest_success_rate = success_rate
          choice = letter
        end
      end
      choice ||= find_any
      choice
    end

    def played_invalid?
      @old_frag == @current_frag || @old_frag + @last_guess == @current_frag
    end

    def played_valid?
      if @old_frag != @current_frag
        return true
      elsif @old_frag[@current_frag].nil? && !@current_frag.empty?
        return true
      else
        false
      end
    end

    def find_any
      @invalids.each_key do |letter|
        @current_possibles.delete(letter)
      end
      @current_possibles.shuffle.pop()
    end

    def save_memory
      add_to_memory dict_string_arr.join("\n")
    end
end
