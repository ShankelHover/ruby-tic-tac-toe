class Game < ApplicationRecord
  EMPTY = "."
  PLAYERS = %w[X O].freeze
  WINNING_LINES = [
    [ 0, 1, 2 ], [ 3, 4, 5 ], [ 6, 7, 8 ], # rows
    [ 0, 3, 6 ], [ 1, 4, 7 ], [ 2, 5, 8 ], # columns
    [ 0, 4, 8 ], [ 2, 4, 6 ]               # diagonals
  ].freeze

  class IllegalMove < StandardError; end

  validates :board, format: { with: /\A[XO.]{9}\z/ }
  validates :current_player, inclusion: { in: PLAYERS }

  def cells
    board.chars
  end

  def winner
    line = WINNING_LINES.find do |a, b, c|
      board[a] != EMPTY && board[a] == board[b] && board[b] == board[c]
    end
    board[line.first] if line
  end

  def draw?
    winner.nil? && !board.include?(EMPTY)
  end

  def over?
    winner.present? || draw?
  end

  def play!(index)
    raise IllegalMove, "Game is over" if over?
    raise IllegalMove, "No such square" unless index.between?(0, 8)
    raise IllegalMove, "Square already taken" unless board[index] == EMPTY

    new_board = board.dup
    new_board[index] = current_player
    self.board = new_board
    self.current_player = next_player unless over?
    save!
  end

  private

  def next_player
    current_player == "X" ? "O" : "X"
  end
end
