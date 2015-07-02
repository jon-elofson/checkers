require_relative 'board'
require_relative 'display'
require_relative 'player'
require_relative 'move_error'
require 'colorize'

class Checkers

  attr_reader :board, :current_player

  def initialize(players)
    @players = arrange_players_in_order(players)
    @board = Board.new
    @display = Display.new(self)
    @last_player = nil
  end

  def arrange_players_in_order(players)
    @players = players
  end

  def play
    until game_over? || @display.save
      find_current_player
      begin
        @current_player.prompt
        @display.render
        make_move unless @display.save
      rescue MoveError
        retry
      end
      break if game_over? || @display.save
      @last_player = @current_player
    end

    if game_over?
      display_winner
      @display.render
    else
      save_game
    end
  end

  def find_current_player
    if @last_player.nil?
      @current_player = @players.first
    else
      @current_player = (@players - [@last_player]).first
    end
  end

  def save_game
    @display.save = false
    File.open("checkers.yml", "w") { |f| f.puts self.to_yaml }
    puts "Your game is saved as 'checkers.yml'"
  end

  def game_over?
    @board.game_over
  end

  def start_pos
    @display.start_pos
  end

  def end_pos
    @display.end_pos
  end

  def make_move
    raise MoveError if start_pos == end_pos
    raise MoveError if @board[*start_pos].empty?
    raise MoveError if  @board[*start_pos].color != @current_player.color
    unless start_pos.nil? && end_pos.nil?
      @board.move(start_pos,end_pos)
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  puts "Would you like to load a saved game?"
  input = gets.chomp
  if input =~ /\A[y]\z/i
    saved_game = YAML::load_file('chess.yml')
    saved_game.play
  else
    puts "Enter Player1's name:"
    p1name = gets.chomp
    puts "Enter Player2's name:"
    p2name = gets.chomp
    a = Player.new(p1name, :light_red)
    b = Player.new(p2name, :light_blue)
    c = Checkers.new([a, b])
    c.board[0,0] = EmptySquare.new
    c.board[1,1] = Pawn.new([1,1],:light_blue,c.board)
    c.play
  end
end
