require_relative 'player'
require 'byebug'

class Game
  LOSING_WORD = 'GHOST'

  HUMAN = Player.new("nobody")

  def initialize(players, file_name="dictionary.txt")
    @dictionary = File.readlines(file_name).map(&:chomp)
    @players = players
    @fragment = ""
    HUMAN.set_streams
  end

  def run
    puts "Game Begin!"
    @round_count = 1
    until winner?
      clear_fragment
      play_round
      update_user_data
      loser = remove_loser
      puts "#{loser} is out of the game." if loser
    end
    puts "#{current_player} wins!"
  end

  def inspect
    "#{object_id} #{scoreboard}"
  end

  attr_reader :players

  private

  def update_user_data
    @players.each do |player|
      begin
        player.commit_memory
      rescue => e
        puts "Unable to save #{player.name}", e.inspect
      end
    end
  end

  def clear_fragment
    @fragment = ""
  end

  def display
    puts (@fragment == '' ? "Round #{@round_count}" : fragment_letters)
  end

  def fragment_letters #extendable method for Spook
    @fragment
  end

  def play_round
    until is_word?
      display
      take_turn
      switch_players!
    end
    HUMAN.set_streams
    round_over_message
    last_player.lose_round
    show_scores
    increase_round_count
  end

  def round_over_message
    puts "#{fragment_letters} is a word! #{last_player} loses the round."
  end

  def take_turn
    @fragment << get_valid_letter
  end

  def get_letter
    user_input = nil
    begin
      letter_error(user_input)
      user_input = current_player.guess(fragment_letters).downcase
    end until letter?(user_input)
    user_input
  end

  def get_valid_letter
    letter = nil
    begin
      fragment_error(letter)
      letter = get_letter
    end until valid_play?(letter)
    HUMAN.set_streams
    print ".#{letter}".colorize(current_player.color)
    switch_io
    letter
  end

  def current_player
    @players.first
  end

  def switch_players!
    @players.rotate!
    # switch_io
    HUMAN.set_streams
    puts "^"
    current_player.set_streams
  end

  def switch_io
    current_player.set_streams
  end
  #
  # def different_io?
  #   current_player.streams_current?
  # end

  def valid_play?(string)
    letter?(string) && valid_fragment?(string)
  end

  def letter?(string)
    ("a".."z").to_a.include?(string)
  end

  def letter_error(string)
    puts "\"#{string}\" is not a valid letter" unless string.nil?
  end

  def valid_fragment?(letter)
    @dictionary.any? {|word| word.start_with?(@fragment + letter)}
  end

  def fragment_error(letter)
    HUMAN.set_streams
    print ".#{letter}".colorize(current_player.color)
    current_player.set_streams
    puts "\"#{@fragment + letter}\" does not begin a word"  unless letter.nil?
  end

  def is_word?
    @dictionary.include?(@fragment)
  end

  def loser?(player)
    score(player) == LOSING_WORD
  end

  def remove_loser
    @players.delete(last_player) if loser?(last_player)
  end

  def winner?
    @players.count == 1
  end

  def show_scores
    puts 'Scores:'
    puts scoreboard
  end

  def scoreboard
    @players.map do |player|
      "\n#{player}: #{score(player)}"
    end.join("")
  end

  def score(player)
    LOSING_WORD[0, player.letter_count].ljust(LOSING_WORD.length, '_')
  end

  def last_player
    @players.last
  end

  def increase_round_count
    @round_count += 1
  end

end

# players = Player.new("Ari",:green), Player.new("Cory",:blue), Player.new('Joe',:light_red)
# g = Game.new(players, "dict.txt")
# g.run
