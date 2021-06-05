class CreatePredictionTeams < ActiveRecord::Migration[6.1]
  def change
    create_table :prediction_teams do |t|
      t.string :name
      t.string :short_name
      t.integer :competetion_id, index: true
      t.boolean :is_active, default: true
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
