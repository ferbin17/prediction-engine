class CreatePredictionUserPredictions < ActiveRecord::Migration[6.1]
  def change
    create_table :prediction_user_predictions do |t|
      t.integer :user_id, index: true
      t.integer :match_id, index: true
      t.integer :home_team_score
      t.integer :away_team_score
      t.integer :score, default: 0
      t.boolean :point_calculated, default: false
      t.boolean :is_active, default: true
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
