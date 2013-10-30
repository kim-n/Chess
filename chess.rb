require_relative 'board'
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


