ruby_files = File.join "**", "*.rb"
Dir.glob(ruby_files) do |file|
  load file unless file == __FILE__
end

def create_players
  @human_player = Player.new "You"
  @prometheus = AiPlayer.new "Prometheus"
  @moneta = MemorizingAiPlayer.new "Moneta"
  @chronus = Ai::BetterMemorizer.new "Chronus"
  @chronus.color = :light_white
  @athena = BayesianAiPlayer.new "Athena"
  @minerva = BayesianAiPlayer.new "Minerva"
  @minerva.color = :white
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
   BayesianAiPlayer.clear_dictionary!
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
