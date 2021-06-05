class CreatePredictionCompetetions < ActiveRecord::Migration[6.1]
  def change
    create_table :prediction_competetions do |t|
      t.string :name
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.integer :no_of_phases
      t.integer :no_of_teams
      t.boolean :setup_completed, default: false
      t.boolean :is_active, default: true
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
