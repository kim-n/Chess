require_relative 'slidingsub'
require_relative 'steppingsub'

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