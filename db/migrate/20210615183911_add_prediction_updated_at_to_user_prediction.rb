class AddPredictionUpdatedAtToUserPrediction < ActiveRecord::Migration[6.1]
  def change
    add_column :prediction_user_predictions, :prediction_updated_at, :datetime
  end
end
