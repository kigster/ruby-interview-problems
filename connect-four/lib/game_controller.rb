# frozen_string_literal: true

class GameController
  attr_accessor :board, :players, :next_player_index

  def initialize(player1, player2)
    self.players = [player1, player2]

    player1.color = COLOR_BLACK
    player2.color = COLOR_RED

    self.board = Board.new

    self.next_player_index = 0
  end

  def start_game
    until game_over?
      next_move
    end
  end

  def game_over?; end

  def take_turn
    move = players[next_player_index].next_move(board)
    board.validate_next_move!(move)
  end
end
