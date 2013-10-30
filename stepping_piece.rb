require_relative "pieces"

class SteppingPiece < Piece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  #HELPER move to Private
  def occupied?(x,y) # board position !nil
    !self.board.grid[x][y].nil?
  end

  #HELPER move to Private
  def inedible?(x,y) # self and another piece share same color
    #p "#{self.color}  #{self.board.grid[x][y].color}"
    self.color == self.board.grid[x][y].color
  end

  def moves   #still has to check that piece eatable
    possible_moves =[]
    self.move_dirs.each do |offset|
      d_x = position[0] + offset[0]
      d_y = position[1] + offset[1]

      if (d_x).between?(0,7) && (d_y).between?(0,7)
        possible_moves << [d_x,d_y] unless occupied?(d_x,d_y) && inedible?(d_x,d_y)
      end
    end

    possible_moves
  end
end