class Piece
  attr_accessor :position, :board, :name, :color

  ORTHOGONAL = [[ 0, 1],[ 1, 0],[-1, 0],[ 0,-1]]
  DIAGONALS  = [[ 1, 1],[-1,-1],[ 1,-1],[-1, 1]]

  def initialize(position, board, name, color)
    self.position = position
    self.board = board
    self.name = name
    self.color = color
  end

  def dup
    piece_dup = self.class.new(position, board, nil,nil)

    piece_dup.position = self.position
    piece_dup.board = self.board
    piece_dup.name = self.name
    piece_dup.color = self.color

    piece_dup
  end


  def valid_moves
    # filters out the #moves of a Piece that would leave the player in check
    possible_moves = self.moves

    possible_moves.delete_if do |pos|
      duped_board = self.board.dup
      duped_board.move!(self.position, pos)
      duped_board.checked?(self.color)
    end

    possible_moves
  end

  def move_into_check?(pos)
    # For each move, duplicate the Board and perform the move.
    # Look to see if the player is in check after the move (Board#check).
  end

end