class Piece
  attr_accessor :position, :board, :name, :color

  def initialize(position, board, name, color)
    self.position = position
    self.board = board
    self.name = name
    self.color = color
  end

  def moves
    #returns array of places that piece can move to
  end

  def valid_moves
    # filters out the #moves of a Piece that would leave the player in check
  end

  def move_into_check?(pos)
    # For each move, duplicate the Board and perform the move.
    # Look to see if the player is in check after the move (Board#check).
  end

end

class SlidingPiece < Piece


  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  def moves
    # uses #move_dirs
    # returns array of places that piece can move to
    # know what directions a piece can move in
  end
end


class SteppingPiece < Piece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  def moves
    # returns array of places that piece can move to
    # know what directions a piece can move in
  end
end

class Knight < SteppingPiece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end
end


class King < SteppingPiece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end
end

class Bishop < SlidingPiece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  def move_dirs

  end
end

class Rook < SlidingPiece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  def move_dirs

  end
end

class Queen < SlidingPiece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  def move_dirs

  end

end

class Castle < SlidingPiece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  def move_dirs

  end
end

class Board
  attr_accessor :board

  def initialize
    self.board = Array.new(8) { Array.new(8) {nil} }
    create_board
  end

  def create_board
    positions = {
      C: [[0,0], [0,7], [7,0], [7,7]],
      N: [[0,1], [0,6], [7,1], [7,6]],
      B: [[0,2], [0,5], [7,2], [7,5]],
      K: [[0,3], [7,3]],
      Q: [[0,4], [7,4]]
    }


    positions.each do |name, positions|
      positions.each do |pos|
        x, y = pos[0], pos[1]
        color = pos[0] == 0 ? :w : :b
        if name == :C
          self.board[x][y] = Castle.new(pos, self, name, color)
        elsif name == :B
          self.board[x][y] = Bishop.new(pos, self, name, color)
        elsif name == :N
          self.board[x][y] = Knight.new(pos, self, name, color)
        elsif name == :K
          self.board[x][y] = King.new(pos, self, name, color)
        elsif name == :Q
          self.board[x][y] = Queen.new(pos, self, name, color)
        end
      end
    end

  end

  def checked?(color)
    # returns whether a player is in check
    # finding the position of the king on the board
    # if any of the opposing pieces can move to that position
  end

  def checkmate?(color)
    # If the player is in check, and if none of the player's pieces have any #valid_moves, then the player is in checkmate.
  end

  def move(start_pos, end_pos)
    # should update the 2d grid and also the moved piece's position.
    # raise exception if: (a) there is no piece at start or (b) the piece cannot move to end
    # can only make valid moves
    # Modify your Board#move method so that it only allows you to make valid moves. Because Board#move needs to call Piece#valid_moves, #valid_moves must not call Board#move. But #valid_moves needs to make a move on the duped board to see if a player is left in check. For this reason, write a method Board#move! which makes a move without checking if it is valid
    # Board#move should raise an exception if it would leave you in check.
  end

  def dup
    # deep dup for #moves_into_check method
  end

  def print_board
    board.each do |row|
      pretty_row = row.map do |piece|
        if piece.nil?
          " "
        else
          "#{piece.name}"
        end
      end
      p pretty_row
    end
  end


end

Board.new.print_board
