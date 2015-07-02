require 'colorize'

class Pawn

  attr_reader :color, :board
  attr_accessor :pos, :king

  def initialize(pos,color,board)
    @pos = pos
    @board = board
    @color = color
    @king = false
    @diffs = find_diffs
  end

  def empty?
    false
  end

  def piece?
    true
  end

  def to_s
     if @king
       return "⬢ "
     else
       return "⬣ "
     end
  end

  def convert_to_king?
    if (color == :light_red && pos[0] == 7)
      become_king
    elsif (color == :light_blue && pos[0] == 0)
      become_king
    end
  end


  def become_king
    @king = true
    @king.freeze
    @diffs = [[-1,-1],[-1,1],[1,-1],[1,1]]
  end

  def dup(board_copy)
    self.new(pos,color,board_copy)
  end

  def find_diffs
    return [[-1,-1],[-1,1]] if @color == :light_blue
    return [[1,-1],[1,1]] if @color == :light_red
  end


  def possible_moves
    pos_moves = []
    @diffs.each do |dx,dy|
      new_pos = [pos[0] + dx, pos[1] + dy]
      jump_pos = [pos[0] + 2 * dx, pos[1] + 2 * dy]
      next if board.on_board?(new_pos) == false
      if board[*new_pos].empty?
        pos_moves << new_pos
      elsif board.on_board?(jump_pos) && board[*jump_pos].empty?
        pos_moves << jump_pos if board[*new_pos].color != color
      end
    end
    pos_moves
  end


end
