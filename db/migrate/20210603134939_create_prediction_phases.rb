class CreatePredictionPhases < ActiveRecord::Migration[6.1]
  def change
    create_table :prediction_phases do |t|
      t.string :name
      t.integer :order, index: true
      t.integer :no_of_matches
      t.boolean :setup_completed, default: false
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.integer :competetion_id, index: true
      t.boolean :phase_completed, default: false
      t.boolean :is_active, default: true
      t.boolean :is_deleted, default: false
      t.timestamps
    end
  end
end
