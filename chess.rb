# PIECE CLASS---------------------
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

# SLIDING PIECE ---------------------

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

class MoveError < StandardError
end

class Board
  attr_accessor :grid

  def initialize(dup = false)
    self.grid = Array.new(8) { Array.new(8) { nil } }
    create_board unless dup
  end

  def create_board
    positions = {
      C: [[0,0], [0,7], [7,0], [7,7]],
      N: [[0,1], [0,6], [7,1], [7,6]],
      B: [[0,2], [0,5], [7,2], [7,5]],
      Q: [[0,3], [7,3]],
      K: [[0,4], [7,4]],
    }

    symbs = {
      N: ["\u2658", "\u265E"],
      B: ["\u2657", "\u265D"],
      C: ["\u2656", "\u265C"],
      Q: ["\u2655", "\u265B"],
      K: ["\u2654", "\u265A"],
      P: ["\u2659", "\u265F"]
    }
    positions.each do |name, positions|
      positions.each do |pos|
        x, y = pos[0], pos[1]
        color = pos[0] == 0 ? :b : :w
        set = pos[0] == 0 ? 1 : 0
        if name == :C
          self.grid[x][y] = Castle.new(pos, self, symbs[name][set], color)
        elsif name == :B
          self.grid[x][y] = Bishop.new(pos, self, symbs[name][set], color)
        elsif name == :N
          self.grid[x][y] = Knight.new(pos, self, symbs[name][set], color)
        elsif name == :K
          self.grid[x][y] = King.new(pos, self, symbs[name][set], color)
        elsif name == :Q
          self.grid[x][y] = Queen.new(pos, self, symbs[name][set], color)
        end
      end
    end

    [1,6].each do |x|
      8.times do |y|
        color = x == 1 ? :b : :w
        set = x == 1 ? 1 : 0
        self.grid[x][y] = Pawn.new([x,y], self, symbs[:P][set], color)
      end
    end
  end  # END BOARD#create_board

  #HELPER move to private
  def find_king(color)

    king = self.grid.flatten.select do |piece|
      !piece.nil? && piece.class == King && piece.color == color
    end

    king.first.position

    # king = color == :w ? "\u2654" : "\u265A"
#     self.grid.each do |row|
#       row.each do |piece|
#         if !piece.nil?
#           return piece.position if piece.name == king && piece.color == color
#         end
#       end
#     end
  end

  #HELPER move to private
  def find_pieces(color)
    # compact + select

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

    oponents.any? do |piece|
      piece.moves.include?(king_pos)
    end

    # checked = false
    # oponents.each do |opponent_piece|
    #   checked = true if opponent_piece.moves.include?(king_pos)
    # end
    # checked
    # returns whether a player is in check
    # finding the position of the king on the board
    # if any of the opposing pieces can move to that position
  end

  def checkmate?(color)
    # checkmate = false
    # if checked?(color)
    #   my_pieces = find_pieces(color)
    #
    #   my_pieces.delete_if do |piece|
    #     piece.valid_moves.empty?
    #   end
    #
    #   checkmate = my_pieces.empty?
    # end
    #
    # checkmate

    checked?(color) && find_pieces(color).all? { |piece| piece.valid_moves.empty? }
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

  def move(start_pos, end_pos, current_color)
    start_x, start_y = start_pos[0], start_pos[1]
    end_x, end_y = end_pos[0], end_pos[1]
    move_to_object = self.grid[start_x][start_y]

    if move_to_object.nil?
      #raise exception there is no piece at start
      raise MoveError.new "Wrong start position, no piece yo"
    elsif !move_to_object.moves.include?(end_pos)
      #raise end position not in possible moves
      raise MoveError.new "Wrong end position, not possible"
    elsif !move_to_object.valid_moves.include?(end_pos)
      #raise exception, that move will leave you in check
      raise MoveError.new "Move not possible, will put you in check"
    elsif move_to_object.color != current_color # FILL THIS IN
      raise MoveError.new "You moved for the wrong team"
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
    self.grid[end_x][end_y].position = e_pos unless self.grid[end_x][end_y].nil?
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

  def pretty_print
    grid.each do |row|
      row.each do |col|
        if col.nil?
          print "-  "
        else
          print "#{col.name}  "
        end
      end
      print "\n"
    end
  end

  def prettier_print
    print "   "
    8.times do |i|
      print "  #{('A'.ord+i).chr}"
    end
    print "\n"
    print "   "
    8.times do |i|
      print "---"
    end

    print "\n\n"
    8.times do |i|
      print "|#{8-i}|  "
      8.times do |j|
        if grid[i][j].nil?
          print "-  "
        else
          print "#{grid[i][j].name}  "
        end
      end
      print "|#{8-i}|\n\n"
    end

    print "   "
    8.times do |i|
      print "---"
    end
    print "\n"
    print "   "
    8.times do |i|
      print "  #{('A'.ord+i).chr}"
    end
    print "\n\n"
  end
end

# GAME class -------------------------------------------------

class Game

  attr_accessor :new_game
  attr_reader :first_player, :second_player

  def initialize
    @new_game = Board.new
    @first_player = HumanPlayer.new(:w) #white
    @second_player = HumanPlayer.new(:b) #black
  end

  def play
    puts "White moves first. Please enter move (ex: f2, f3)"

    current_player = @first_player
    begin
      while !@new_game.checkmate?(current_player.color)
        @new_game.prettier_print
        move_arr = current_player.play_turn
        new_game.move(move_arr[0], move_arr[1], current_player.color)
        current_player = current_player.color == :w ? @second_player : @first_player
      end
    rescue MoveError => e
      puts "Error due to #{e}"
      retry
    end

    print "You lost #{current_player.color} player. You suck."
  end

end

class HumanPlayer

  attr_reader :color

  def initialize(color)
    @color = color
  end

  def play_turn
    puts "Please make your move, #{self.color}:"
    user_input = gets.chomp
    move_arr = convert_input_to_array(user_input.split(', '))
  end

  def convert_input_to_array(user_input)
    convert_cols = {
      "A" => 0,
      "B" => 1,
      "C" => 2,
      "D" => 3,
      "E" => 4,
      "F" => 5,
      "G" => 6,
      "H" => 7
    }

    start_pos, end_pos = user_input[0].reverse.split(''), user_input[1].reverse.split('') # "2f, 2f"

    start_pos[0] = 8 - start_pos[0].to_i
    start_pos[1] = convert_cols[start_pos[1].upcase!]
    end_pos[0]   = 8 - end_pos[0].to_i
    end_pos[1]   = convert_cols[end_pos[1].upcase!]

    p [[start_pos[0], start_pos[1]], [end_pos[0], end_pos[1]]]
    [[start_pos[0], start_pos[1]], [end_pos[0], end_pos[1]]]
  end

end



#--------T-E-S-T-S---------


Game.new.play

# game = Board.new
#
# new_game = game.dup
#
# game.prettier_print
# puts
#
# #TEST FOR CHECKMATE
#
# game.move!([6,5], [5,5])
# game.move!([1,4], [3,4])
# game.move!([6,6], [4,6])
# game.move!([0,3], [4,7])
#
# game.prettier_print
#
# p "checkmate w #{game.checkmate?(:w)}"
# p "checkmate b #{game.checkmate?(:b)}"



# # TEST PAWN
# pawn = game.grid[1][0]
# p "pawn.name #{pawn.name}"
# p pawn.moves
# game.move!([1,0], [2,0])
# game.move!([6,1], [3,1])
#
# game.print_board
# puts
# p pawn.moves
#
# #-------------

# # move Black Queen
# game.move!([0,4], [3,7])
#
# # move White Queen
# game.move!([7,4], [6,3])
#
# game.move!([7,3], [4,7])
#
# game.print_board
# puts
#
# b_queen = game.grid[3][7]
#
# w_queen = game.grid[6][3]
#
#
# #print w_queen.moves
#
#
# p "Valid moves of white queen at position #{w_queen.position}"
# p w_queen.valid_moves
#
# p "Valid moves of black queen at position #{b_queen.position}"
# p b_queen.valid_moves
#
#
# p "w checked? #{game.checked?(w_queen.color)}"
# p "b checked? #{game.checked?(b_queen.color)}"
#
# p "w checkmate? #{game.checkmate?(w_queen.color)}"
# p "b checkmate? #{game.checkmate?(b_queen.color)}"

#-- Test pawn


