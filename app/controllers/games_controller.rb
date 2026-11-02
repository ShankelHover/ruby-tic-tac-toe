class GamesController < ApplicationController
  before_action :set_game

  def index
  end

  def move
    @game.play!(params[:index].to_i)
    redirect_to root_path
  rescue Game::IllegalMove => e
    redirect_to root_path, alert: e.message
  end

  def reset
    @game.reset!
    redirect_to root_path
  end

  private

  def set_game
    @game = Game.find_by(id: session[:game_id]) || Game.create!
    session[:game_id] = @game.id
  end
end
