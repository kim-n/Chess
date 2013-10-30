require_relative 'sliding_piece'

class Queen < SlidingPiece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  def move_dirs
    [
      [ 0, 1],  #horizontals & verticals
      [ 1, 0],
      [-1, 0],
      [ 0,-1],
      [ 1, 1],  #diagonals
      [-1,-1],
      [ 1,-1],
      [-1, 1]
    ]
  end

end



class Bishop < SlidingPiece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  def move_dirs
    [
      [ 1, 1],
      [-1,-1],
      [ 1,-1],
      [-1, 1]
    ]
  end
end

class Castle < SlidingPiece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  def move_dirs
    [
      [ 0, 1],
      [ 1, 0],
      [-1, 0],
      [ 0,-1]
    ]

  end
end