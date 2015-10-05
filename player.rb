require 'colorize'

class Player


  attr_accessor :in_stream, :out_stream, :letter_count, :name

  def initialize(name, color = :blue, streams = [out_stream=STDIN, in_stream=STDOUT])
    @name = name
    @letter_count = 0
    @color = color
    @out_stream, @in_stream = streams
    @streams = streams
  end

  def guess(fragment)
    set_streams
    @current_frag = fragment
    prompt
    get_response
  end

  def to_s
    name.colorize(@color)
  end

  def lose_round
    @letter_count += 1
  end

  def set_streams
    $stdin, $stdout = @streams
  end

  def streams_current?
    @out_stream == $stdin && @in_stream == $stdout
  end

  def prompt
    $stdout.puts "The fragment is currently: #{@current_frag}"
    $stdout.print "Enter a letter, #{self}: "
  end

  def get_response
    $stdin.gets.chomp
  end

end
