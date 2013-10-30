require_relative 'stepping_piece'

class Knight < SteppingPiece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  def move_dirs
    # uses #move_dirs
    # returns array of places that piece can move to
    # know what directions a piece can move in
    [
      [-2, -1],
      [-2,  1],
      [-1,  2],
      [-1, -2],
      [ 1,  2],
      [ 1, -2],
      [ 2, -1],
      [ 2,  1]
    ]
  end
end

class Pawn < SteppingPiece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  def moves
    foward =     [
      [ 1, 0], #black
    ]

    initial =     [
      [ 2, 0], #black
    ]

    diagonal =     [
      [ 1, 1], #black
      [ 1,-1], #black
    ]

    possible_moves = []
    offsets = foward + diagonal

    if ( (position[0] == 1 && self.color == :b) || (position[0] == 6 && self.color == :w) )
      offsets += initial
    end

    offsets.each do |offset|
      offset[0] = 0-offset[0] if color == :w #turns x negative
      d_x = position[0] + offset[0]
      d_y = position[1] + offset[1]

      if (d_x).between?(0,7) && (d_y).between?(0,7)
        if offset[1] != 0 # a diagonal offset
          possible_moves << [d_x,d_y] if (occupied?(d_x,d_y) && !inedible?(d_x,d_y))
        else
          possible_moves << [d_x,d_y] unless occupied?(d_x,d_y)
        end
      end

    end
    possible_moves
  end

end

class King < SteppingPiece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  def move_dirs
    # uses #move_dirs
    # returns array of places that piece can move to
    # know what directions a piece can move in
    [
      [ 0, 1],
      [ 1, 0],
      [-1, 0],
      [ 0,-1]
    ]
  end
end
