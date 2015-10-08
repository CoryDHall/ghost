ruby_files = File.join "**", "*.rb"
Dir.glob(ruby_files) do |file|
  load file unless file == __FILE__
end

def create_players
  @human_player = Player.new "You"
  @prometheus = AiPlayer.new "Prometheus"
  @moneta = MemorizingAiPlayer.new "Moneta"
  @athena = BayesianAiPlayer.new "Athena"
  nil
end

def setup_game (player1, player2)
  player1.letter_count, player2.letter_count = 0, 0
  @game = Game.new([player1, player2])
end

def run_game (player1 = @moneta, player2 = @prometheus)
  setup_game player1, player2
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

def _make_athena_stat (against = @prometheus)
  run_game against, @athena
  @winners[@game.players.first.to_s] += 1
  run_game @athena, against
  @winners[@game.players.first.to_s] += 1
end

def make_athena_stats (times = 10, resolution = 3, against = @prometheus)
  @winners = Hash.new { |hash, key| hash[key] = 0 }
  ratios = []
  times.times do
    resolution.times do
      _make_athena_stat
    end
    ratios << "#{@winners.keys}\t#{@winners.values}"
  end
  ratios
end

create_players
