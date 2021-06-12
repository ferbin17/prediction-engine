class AddScoreSubmittedToMatch < ActiveRecord::Migration[6.1]
  def change
    add_column :prediction_matches, :score_submitted, :boolean, default: false
  end
end
