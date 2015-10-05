require_relative 'game.rb'

class Spook < Game

  attr_reader :dictionary

  def initialize(players, file_name="dictionary.txt")
    @dictionary = Spook.make_dictionary(file_name)
    @players = players
    @fragment = ""
  end

  def self.make_dictionary(file_name)
    words = File.readlines(file_name).map(&:chomp)
    dictionary = Hash.new() {[]}
    words.each do |word|
      dictionary[Spook.word_to_hash(word)] += [word]
    end
    dictionary
  end

  def fragment_hash
    Spook.word_to_hash(@fragment)
  end

  def self.word_to_hash(word)
    hash = {}
    hash.default = 0
    word.split('').each do |char|
      hash[char] += 1
    end
    hash
  end

  def fragment_subset?(word) #word is hash
    word_subset(@fragment, word)
  end

  def word_subset?(sub_str_hash, word)
    sub_str_hash.all? do |key, value|
      value <= word[key]
    end
  end

  def valid_fragment?(letter)
    @dictionary.each.any? do |hash, _|
      word_subset?(Spook.word_to_hash(@fragment + letter), hash)
    end
  end

  def is_word?
    @dictionary.has_key?(fragment_hash)
  end

  def round_over_message
    puts "#{fragment_letters} matches #{@dictionary[fragment_hash].inspect}"
  end

  def fragment_error(letter)
    unless letter.nil?
      HUMAN.set_streams
      print "."
      current_player.set_streams
      puts "#{fragment_letters} and #{letter.inspect} do not exist in any word"
    end
  end

  def fragment_letters
    "#{@fragment.split("").inspect}"
  end

end

# s = Spook.new([Player.new("nobody"),Player.new("somebody", :red)],"dict.txt")
# # p s.dictionary
# s.run
