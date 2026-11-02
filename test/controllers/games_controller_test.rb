require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_select ".board .cell", 9
    assert_select ".status", /X to move/
  end

  test "clicking a square places the current player's mark" do
    post move_game_url, params: { index: 4 }
    assert_redirected_to root_url

    follow_redirect!
    assert_select ".cell[data-index='4']", "X"
    assert_select ".status", /O to move/
  end

  test "players alternate between moves" do
    post move_game_url, params: { index: 0 }
    post move_game_url, params: { index: 1 }

    follow_redirect!
    assert_select ".cell[data-index='0']", "X"
    assert_select ".cell[data-index='1']", "O"
  end

  test "playing a taken square shows an error" do
    post move_game_url, params: { index: 4 }
    post move_game_url, params: { index: 4 }

    follow_redirect!
    assert_select ".alert", "Square already taken"
  end

  test "reset clears the board" do
    post move_game_url, params: { index: 4 }
    post reset_game_url
    assert_redirected_to root_url

    follow_redirect!
    assert_select ".cell.playable", 9
    assert_select ".status", /X to move/
  end
end
