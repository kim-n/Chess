# PIECE CLASS---------------------
class Piece
  attr_accessor :position, :board, :name, :color

  def initialize(position, board, name, color)
    self.position = position
    self.board = board
    self.name = name
    self.color = color
  end

  def dup
    piece_dup = self.class.new(nil,nil,nil,nil)

    piece_dup.position = self.position
    piece_dup.board = self.board
    piece_dup.name = self.name
    piece_dup.color = self.color

    piece_dup
  end

  def moves
    #returns array of places that piece can move to
    p "Piece"
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

# SLIDING PIECE ---------------------

class SlidingPiece < Piece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  #HELPER move to Private
  def occupied?(x,y) # board position !nil
    !self.board.board[x][y].nil? # if not nil, then occupied == true
  end

  #HELPER move to Private
  def edible?(x,y) # self and another piece share same color
    self.color != self.board.board[x][y].color
  end

  def moves #still has to check that piece eatable
    possible_moves = []
    self.move_dirs.each do |offset|
      d_x = position[0] + offset[0]
      d_y = position[1] + offset[1]
      while (d_x).between?(0,7) && (d_y).between?(0,7)
        if occupied?(d_x,d_y)
          possible_moves << [d_x,d_y] if edible?(d_x,d_y)
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

# STEPPING PIECE ---------------------

class SteppingPiece < Piece

  def initialize(position, board, name, color)
    super(position, board, name, color)
  end

  #HELPER move to Private
  def occupied?(x,y) # board position !nil
    !self.board.board[x][y].nil?
  end

  #HELPER move to Private
  def inedible?(x,y) # self and another piece share same color
    #p "#{self.color}  #{self.board.board[x][y].color}"
    self.color == self.board.board[x][y].color
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

# INDIVIDUAL PIECES ---------------------

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

  # def dup
  #   piece_dup = Knight.new(nil,nil,nil,nil)
  #
  #   piece_dup.position = self.position
  #   piece_dup.board = self.board
  #   piece_dup.name = self.name
  #   piece_dup.color = self.color
  #
  #   piece_dup
  # end

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

# SLIDING PIECE ---------------------

class Board
  attr_accessor :board

  def initialize(dup = false)
    self.board = Array.new(8) { Array.new(8) {nil} }
    create_board unless dup
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
        color = pos[0] == 0 ? :b : :w
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
  end  # END BOARD#create_board

  #HELPER move to private
  def find_king(color)
    self.board.each do |row|
      row.each do |piece|
        if !piece.nil?
          return piece.position if piece.name == :K && piece.color == color
        end
      end
    end
  end

  #HELPER move to private
  def find_oponents(color)
    oponent_color = color == :w ? :b : :w
    oponents = []
    self.board.each do |row|
      row.each do |piece|
        next if piece.nil?
        oponents << piece if piece.color == oponent_color
      end
    end

    oponents
  end

  def checked?(color)
    king_pos = find_king(color)
    oponents = find_oponents(color)
    checked = false
    oponents.each do |opponent_piece|
      checked = true if opponent_piece.moves.include?(king_pos)
    end

    checked
    # returns whether a player is in check
    # finding the position of the king on the board
    # if any of the opposing pieces can move to that position
  end

  def checkmate?(color)
    # If the player is in check, and if none of the player's pieces have any #valid_moves, then the player is in checkmate.
  end


  def dup
    dup_board = self.class.new(true)

    8.times do |x|
      8.times do |y|
        unless self.board[x][y].nil?
          dup_board.board[x][y] = self.board[x][y].dup  #dup the piece
          dup_board.board[x][y].board = dup_board       #sets dupped piece.board to dupped board
        end
      end
    end
    
    dup_board
  end

  def move(start_pos, end_pos)
    start_x, start_y = start_pos[0], start_pos[1]
    end_x, end_y = end_pos[0], end_pos[1]

    if self.board[start_x][start_x].nil?
      #raise exception there is no piece at start
    end
    if !self.board[start_x][start_y].moves.include?(board[end_x][end_].position)
      #raise end position not in possible moves
    end

    # should update the 2d grid and also the moved piece's position.
    # raise exception if: (a) there is no piece at start or (b) the piece cannot move to end
    # can only make valid moves
    # Modify your Board#move method so that it only allows you to make valid moves. Because Board#move needs to call Piece#valid_moves, #valid_moves must not call Board#move. But #valid_moves needs to make a move on the duped board to see if a player is left in check. For this reason, write a method Board#move! which makes a move without checking if it is valid
    # Board#move should raise an exception if it would leave you in check.
  end


  def move!(s_pos, e_pos)
    start_x, start_y = s_pos[0], s_pos[1]
    end_x, end_y = e_pos[0], e_pos[1]

    #Removes stray pointers
    self.board[end_x][end_y].board = nil if !self.board[end_x][end_y].nil?

    self.board[end_x][end_y] = self.board[start_x][start_y]
    self.board[end_x][end_y].position = e_pos if !self.board[end_x][end_y].nil?
    self.board[start_x][start_y] = nil
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




#--------T-E-S-T-S---------

game = Board.new

new_game = game.dup

game.print_board
puts


# move White Queen
game.move!([0,4], [1,3])

# move Black Queen
game.move!([7,4], [6,3])


game.print_board
puts

w_queen = game.board[1][3]

b_queen = game.board[6][3]


#print w_queen.moves



print w_queen.valid_moves




