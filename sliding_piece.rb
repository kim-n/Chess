require_relative "pieces"

class SlidingPiece < Piece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  #HELPER move to Private
  def occupied?(x, y) # board position !nil
    !!self.board.grid[x][y] # if not nil, then occupied == true
  end

  #HELPER move to Private
  def edible?(x,y) # self and another piece share same color
    self.color != self.board.grid[x][y].color
  end

  def moves #still has to check that piece eatable
    possible_moves = []
    self.move_dirs.each do |offset|
      d_x = position[0] + offset[0]
      d_y = position[1] + offset[1]
      while (d_x).between?(0,7) && (d_y).between?(0,7)
        if occupied?(d_x,d_y)
          possible_moves << [d_x, d_y] if edible?(d_x, d_y)
          break
        else
          possible_moves << [d_x, d_y]
          d_x = d_x + offset[0]
          d_y = d_y + offset[1]
        end
      end
    end

    possible_moves
  end
end
