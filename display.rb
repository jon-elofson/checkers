require 'io/console'
require 'colorize'

class Display

  attr_reader :board
  attr_accessor :cpos, :start_pos, :end_pos, :turn, :save


  def initialize(game)
    @game = game
    @board = game.board
    @save = false
  end

  def read_char
  STDIN.echo = false
  STDIN.raw!

  input = STDIN.getch
  if input == "\e" then
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end

  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  def interpret_char
    c = read_char
    case c
    when "\e[A"
      cpos[0] -= 1 unless cpos[0] == 0
    when "\e[B"
      cpos[0] += 1 unless cpos[0] == 7
    when "\e[C"
      cpos[1] += 1 unless cpos[1] == 7
    when "\e[D"
      cpos[1] -= 1 unless cpos[1] == 0
    when "\r"
      self.start_pos = cpos.clone
    when " "
      self.end_pos = cpos.clone
      @turn = false if @start_pos != nil
    when "q"
        exit 0
    end
  end

  def render
    @cpos = [0,0]
    @start_pos = nil
    @end_pos = nil
    @turn = true
    while @turn && !@save
      system("clear")
      show_board
      interpret_char
    end

  end

  def show_board
    puts
    puts "#{@game.current_player.name}'s turn! (#{@game.current_player.dispcolor})".center(26)
    puts '     ' + ('A'..'H').to_a.join(" ")
    8.times do |row|
      print_row = ''
      8.times do |col|
        pos = board[row, col]
        if start_pos == [row,col]
          print_row << pos.to_s.colorize(:color => pos.color,:background => :magenta)
        elsif start_pos != nil && board[*start_pos].possible_moves.include?([row,col]) &&
          cpos != [row,col]
          print_row << pos.to_s.colorize(:background => :green)
        elsif cpos == [row,col]
          print_row << pos.to_s.colorize(:color => pos.color,:background => :light_yellow)
        elsif start_pos.nil? && board[*cpos].possible_moves.include?([row,col])
          print_row << pos.to_s.colorize(:background => :green)
        elsif (row.even? && col.odd?) || (row.odd? && col.even?)
          print_row << pos.to_s.colorize(:background => :black)
        else
          print_row << pos.to_s.colorize(:color => pos.color,:background => :light_white)
        end
      end
      puts "    " + (8 - row).to_s + print_row
    end
    puts "⬣ = Pawn, ⬢ = King".center(26)
    nil
  end
end
