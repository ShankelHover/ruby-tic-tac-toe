require "test_helper"

class GameTest < ActiveSupport::TestCase
  test "a new game has an empty board and X to move" do
    game = Game.create!

    assert_equal [ Game::EMPTY ] * 9, game.cells
    assert_equal "X", game.current_player
    assert_not game.over?
  end

  test "players alternate turns" do
    game = games(:new_game)

    game.play!(4)
    assert_equal "X", game.cells[4]
    assert_equal "O", game.current_player

    game.play!(0)
    assert_equal "O", game.cells[0]
    assert_equal "X", game.current_player
  end

  test "moves are saved to the database" do
    game = games(:new_game)
    game.play!(4)

    assert_equal "....X....", game.reload.board
  end

  test "cannot play a taken square" do
    game = games(:in_progress)

    error = assert_raises(Game::IllegalMove) { game.play!(4) }
    assert_equal "Square already taken", error.message
  end

  test "cannot play off the board" do
    game = games(:new_game)

    assert_raises(Game::IllegalMove) { game.play!(9) }
    assert_raises(Game::IllegalMove) { game.play!(-1) }
  end

  test "detects a row win" do
    assert_equal "X", Game.new(board: "XXXOO....").winner
  end

  test "detects a column win" do
    assert_equal "O", Game.new(board: "OX.OX.O..").winner
  end

  test "detects a diagonal win" do
    assert_equal "X", Game.new(board: "X.O.XO..X").winner
  end

  test "no winner on an unfinished board" do
    assert_nil Game.new(board: "XO.......").winner
  end

  test "a full board with no winner is a draw" do
    game = Game.new(board: "XOXXOOOXX")

    assert_nil game.winner
    assert game.draw?
    assert game.over?
  end

  test "the winning move ends the game and keeps the winner as current player" do
    game = Game.create!(board: "XX.OO....")
    game.play!(2)

    assert_equal "X", game.winner
    assert_equal "X", game.current_player
    assert_raises(Game::IllegalMove) { game.play!(8) }
  end

  test "validates board and player" do
    assert_not Game.new(board: "XXX").valid?
    assert_not Game.new(board: "ABCDEFGHI").valid?
    assert_not Game.new(current_player: "Z").valid?
  end
end
