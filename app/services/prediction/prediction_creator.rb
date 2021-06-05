require_relative "application_service"

module Prediction
  class PredictionCreator < ApplicationService
    def initialize(user, prediction_params)
      @user = user
      @prediction_params = prediction_params
    end
    
    def call
      @match = Match.find_by_id(@prediction_params[:match_id])
      @prediction = @user.user_predictions.find_or_create_by(match_id: @match.id)
      unless @prediction.update(@prediction_params)
        return @prediction.errors.full_messages
      end
      return []
    end
  end
end