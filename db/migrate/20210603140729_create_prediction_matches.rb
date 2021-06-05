class CreatePredictionMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :prediction_matches do |t|
      t.integer :home_team_id, index: true
      t.integer :home_team_score, default: 0
      t.integer :away_team_id, index: true
      t.integer :away_team_score, default: 0
      t.boolean :match_ended, default: false
      t.datetime :match_time
      t.integer :phase_id, index: true
      t.integer :competetion_id, index: true
      t.boolean :is_active, default: true
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
