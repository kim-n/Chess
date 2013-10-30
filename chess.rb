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
    # returns array of places that piece can move to
    # this should never be called, subclasses version should be called
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
    !self.board.grid[x][y].nil? # if not nil, then occupied == true
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
  attr_accessor :grid

  def initialize(dup = false)
    self.grid = Array.new(8) { Array.new(8) {nil} }
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
          self.grid[x][y] = Castle.new(pos, self, name, color)
        elsif name == :B
          self.grid[x][y] = Bishop.new(pos, self, name, color)
        elsif name == :N
          self.grid[x][y] = Knight.new(pos, self, name, color)
        elsif name == :K
          self.grid[x][y] = King.new(pos, self, name, color)
        elsif name == :Q
          self.grid[x][y] = Queen.new(pos, self, name, color)
        end
      end
    end
  end  # END BOARD#create_board

  #HELPER move to private
  def find_king(color)
    self.grid.each do |row|
      row.each do |piece|
        if !piece.nil?
          return piece.position if piece.name == :K && piece.color == color
        end
      end
    end
  end

  #HELPER move to private
  def find_pieces(color)
    pieces = []
    self.grid.each do |row|
      row.each do |piece|
        next if piece.nil?
        pieces << piece if piece.color == color
      end
    end

    pieces
  end

  def checked?(color)
    king_pos = find_king(color)
    oponent_color = color == :w ? :b : :w
    oponents = find_pieces(oponent_color)
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
    checkmate = false
    if checked?(color)
      my_pieces = find_pieces(color)

      my_pieces.delete_if do |piece|
        piece.valid_moves.empty?
      end

      checkmate = my_pieces.empty?
    end

    checkmate
    # If the player is in check, and if none of the player's pieces have any #valid_moves, then the player is in checkmate.
  end


  def dup
    dup_board = self.class.new(true)

    8.times do |x|
      8.times do |y|
        unless self.grid[x][y].nil?
          dup_board.grid[x][y] = self.grid[x][y].dup  #dup the piece
          dup_board.grid[x][y].board = dup_board       #sets dupped piece.board to dupped board
        end
      end
    end

    dup_board
  end

  def move(start_pos, end_pos)
    start_x, start_y = start_pos[0], start_pos[1]
    end_x, end_y = end_pos[0], end_pos[1]
    move_to_object = self.grid[start_x][start_y]

    if move_to_object.nil?
      #raise exception there is no piece at start
      raise ArgumentError.new "Wrong start position, no piece yo"
    elsif !move_to_object.moves.include?(grid[end_x][end_y].position)
      #raise end position not in possible moves
      raise ArgumentError.new "Wrong end position, not possible"
    elsif !move_to_object.valid_moves.include?(end_pos)
      #raise exception, that move will leave you in check
      raise ArgumentError.new "Move not possible, will put you in check"
    else
      # make move
      move!(start_pos, end_pos)
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
    self.grid[end_x][end_y].board = nil if !self.grid[end_x][end_y].nil?

    self.grid[end_x][end_y] = self.grid[start_x][start_y]
    self.grid[end_x][end_y].position = e_pos if !self.grid[end_x][end_y].nil?
    self.grid[start_x][start_y] = nil
  end


  def print_board
    grid.each do |row|
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


# move Black Queen
game.move!([0,4], [3,7])

# move White Queen
game.move!([7,4], [6,3])

game.move!([7,3], [4,7])

game.print_board
puts

b_queen = game.grid[3][7]

w_queen = game.grid[6][3]


#print w_queen.moves


p "Valid moves of white queen at position #{w_queen.position}"
p w_queen.valid_moves

p "Valid moves of black queen at position #{b_queen.position}"
p b_queen.valid_moves


p "w checked? #{game.checked?(w_queen.color)}"
p "b checked? #{game.checked?(b_queen.color)}"

p "w checkmate? #{game.checkmate?(w_queen.color)}"
p "b checkmate? #{game.checkmate?(b_queen.color)}"
