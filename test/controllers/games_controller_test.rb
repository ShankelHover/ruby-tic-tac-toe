require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_select ".board .cell", 9
    assert_select ".status", /Your move/
    assert_select ".difficulty-option.selected", "Random"
  end

  test "clicking a square places your mark and the computer replies" do
    post move_game_url, params: { index: 4 }
    assert_redirected_to root_url

    follow_redirect!
    assert_select ".cell[data-index='4']", "X"
    assert_select ".cell", text: "O", count: 1
    assert_select ".status", /Your move/
  end

  test "playing a taken square shows an error" do
    post move_game_url, params: { index: 4 }
    post move_game_url, params: { index: 4 }

    follow_redirect!
    assert_select ".alert", "Square already taken"
  end

  test "choosing perfect makes the computer block" do
    patch game_url, params: { difficulty: "perfect" }
    follow_redirect!
    assert_select ".difficulty-option.selected", "Perfect"

    # Against a corner opening, the center is O's only non-losing reply.
    post move_game_url, params: { index: 0 }
    follow_redirect!
    assert_select ".cell[data-index='4']", "O"

    post move_game_url, params: { index: 1 }
    follow_redirect!
    assert_select ".cell[data-index='2']", "O"
  end

  test "an unknown difficulty is ignored" do
    patch game_url, params: { difficulty: "cheating" }

    follow_redirect!
    assert_select ".difficulty-option.selected", "Random"
  end

  test "reset clears the board" do
    post move_game_url, params: { index: 4 }
    post reset_game_url
    assert_redirected_to root_url

    follow_redirect!
    assert_select ".cell.playable", 9
    assert_select ".status", /Your move/
  end
end
