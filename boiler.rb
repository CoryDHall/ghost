ruby_files = File.join "**", "*.rb"
Dir.glob(ruby_files) do |file|
  load file unless file == __FILE__
end

def create_players
  @human_player = Player.new "You"
  @prometheus = AiPlayer.new "Prometheus"
  @moneta = MemorizingAiPlayer.new "Moneta"
  nil
end

def setup_game (player1, player2)
  create_players
  @game = Game.new([player1, player2])
end

def run_game (player1 = @moneta, player2 = @prometheus)
  setup_game @moneta, @prometheus
  @game.run
end
