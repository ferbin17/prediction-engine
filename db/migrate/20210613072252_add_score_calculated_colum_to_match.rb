class AddScoreCalculatedColumToMatch < ActiveRecord::Migration[6.1]
  def change
    add_column :prediction_matches, :score_calculated, :boolean, default: false
  end
end
