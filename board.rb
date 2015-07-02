require_relative 'empty_square'
require_relative 'piece'
require_relative 'display'
require_relative 'move_error'
require 'byebug'
require 'colorize'

class Board

  attr_reader :white_captured, :black_captured

    def initialize(flag=true)
      @grid = Array.new(8) { Array.new(8) { EmptySquare.new } }
      @white_captured = []
      @black_captured = []
      populate_board if flag
    end

    def [](row,col)
      @grid[row][col]
    end

    def []=(row,col,value)
      @grid[row][col] = value
    end

    def on_board?(position)
      position.all? { |i| i.between?(0, 7) }
    end

    def populate_board
      populate_pieces(:light_red)
      populate_pieces(:light_blue)
      self[0,0].king = true
    end

    def populate_pieces(color)
      color == :light_red ? rows = [0,1,2] : rows = [5,6,7]
      rows.each do |row|
        8.times do |col|
          if row.even? && col.even?
            self[row, col] = Pawn.new([row, col],color,self)
          elsif row.odd? && col.odd?
            self[row, col] = Pawn.new([row, col],color,self)
          end
        end
      end
    end

    def occupied?(pos)
      self[*pos].piece?
    end

    def empty?(pos)
      self[*pos].empty?
    end

    def determine_move_diff(start_pos,end_pos)
        result = [end_pos[0] - start_pos[0], end_pos[1] - start_pos[1]]
        if result.any? { |pos| pos > 1 || pos < -1 }
          result = result.map { |pos| pos / 2 }
        end
        result
    end

    def move(start_pos,end_pos)
      if valid_move?(start_pos,end_pos)
        diff = determine_move_diff(start_pos, end_pos)
        until start_pos == end_pos
          int_pos = [start_pos[0] + diff[0], start_pos[1] + diff[1]]
          self[*int_pos] = self[*start_pos]
          self[*start_pos] = EmptySquare.new
          self[*int_pos].pos = end_pos
          self[*int_pos].convert_to_king?
          start_pos = int_pos
        end
      else
        puts "Can't make that move! Try again".colorize(:red)
        sleep(1)
        raise MoveError
      end
    end

    def game_over
      false
    end

    def valid_move?(spos,epos)
      return false if on_board?(epos) == false
      epiece = self[*epos]
      spiece = self[*spos]
      if spiece.possible_moves.include?(epos)
        return true
      end
      false
    end

    def capture(piece)

    end

    def deep_dup
      board_copy = Board.new(false)
      8.times do |row|
        8.times do |col|
          board_copy[row,col] = self[row,col].dup(board_copy)
        end
      end
      board_copy
    end

end
