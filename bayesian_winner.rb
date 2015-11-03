require_relative 'memorizing_aiplayer.rb'

class Ai::BayesianWinner < Ai::Bayesian

  DIR = "bayesian_w"

  def lose_round
    super
    @_dictionary[@last_guess][:losses] += 1
    @total_losses += 1
    save_memory
  end

  private

    attr_accessor :last_guess

    def set_vars
      @color = :light_black
      @memory_file = "#{DIR}/current.dict.txt"
      @_dictionary = Ai::BayesianWinner.parse(@memory_file)
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
      l = @_dictionary[letter][:losses]
      l == 0 ? 0.0 : @_dictionary[letter][:valids] / l
    end

    def chance_loss(letter)
      l = @_dictionary[letter][:losses]
      l == 0 ? 1.0 : l / @total_losses
    end

    def valids_to_losses
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
        success_rate = (1 - chance_valid(letter)) / (valids_to_losses / chance_loss(letter))
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
