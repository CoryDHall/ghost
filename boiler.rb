ruby_files = File.join "**", "*.rb"
Dir.glob(ruby_files) do |file|
  load file unless file == __FILE__
end

def create_players
  @human_player = Player.new "You"
  @prometheus = Ai::BruteForce.new "Prometheus"
  @moneta = Ai::Memorizer.new "Moneta"
  @chronus = Ai::BetterMemorizer.new "Chronus"
  @chronus.color = :light_white
  @athena = Ai::BayesianSpeedy.new "Athena"
  @nike = Ai::BayesianWinner.new "Nike"
  # @nike.color = :white
  nil
end

def setup_game (*players)
  players.each do |player|
    player.letter_count = 0
  end
  @game = Game.new(players)
end

def run_game (player1 = @moneta, player2 = @prometheus, players)
  setup_game player1, player2, *players
  @game.run
end

def athena_vs_moneta
  run_game @athena, @moneta
end

def human_vs_athena
  run_game @athena, @human_player
end

def athena_vs_prometheus
  run_game @athena, @prometheus
end

def clear_athena
   Ai::BayesianSpeedy.clear_dictionary!
end

def clear_memories
  mem_players = [@chronus, @athena, @nike]
  mem_players.each do |player|
    player.dump_memory
    player.class.clear_dictionary!
  end
  nil
end

def run_all(slice = nil)
  players = [@prometheus, @chronus, @athena, @nike].shuffle
  slice ||= players.length
  setup_game *players.take(slice)
  @game.run
end

def _make_athena_stat (against = [@moneta, @prometheus])
  players = against + [@athena]
  run_game *players.shuffle
  @winners[@game.players.first.to_s] += 1
end

def make_athena_stats (times = 10, resolution = 3, *against)
  against ||= [@moneta, @prometheus]
  @winners = Hash.new { |hash, key| hash[key] = 0 }
  ratios = []
  times.times do
    resolution.times do
      _make_athena_stat against
    end
    ratios << "#{@winners.keys}\t#{@winners.values}"
  end
  ratios
end

create_players
