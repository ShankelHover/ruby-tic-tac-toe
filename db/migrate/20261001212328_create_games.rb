class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :board, null: false, default: "........."
      t.string :current_player, null: false, default: "X"

      t.timestamps
    end
  end
end
