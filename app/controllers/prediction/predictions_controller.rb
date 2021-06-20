require_dependency "prediction/application_controller"
require_dependency "../services/prediction/prediction_creator"

module Prediction
  class PredictionsController < ApplicationController
    before_action :check_player_permission, except: [:table]
    
    # Create predictions
    def predict
      fetch_matches
      @user_predictions = @current_user.user_predictions_in_phase(@phase.id) if @phase
      if request.post?
        @errors = PredictionCreator.call(@current_user, prediction_params)
        flash.now[:success] = (@errors.empty? ? t(:prediction_saved) : nil)
        @match = Match.find_by_id(prediction_params[:match_id])
        @prediction = @current_user.user_predictions.find_by_match_id(prediction_params[:match_id])
        respond_to :js
      end
    end
    
    # Prediction form popup
    def match_popup
      @match = Match.find_by_id(params[:id])
      if @match
        @phase = @match.phase
        @prediction = @current_user.user_predictions.where(match_id: @match.id).first
      end
    end
    
    # Point table
    def table
      @users = User.players.joins("left join (select user_id, count(id) as calculated_count from prediction_user_predictions where point_calculated = TRUE group by user_id) as calculated_table on prediction_users.id = calculated_table.user_id left join (select user_id, count(id) as all_predictions_count from prediction_user_predictions group by user_id) as predictions_table on prediction_users.id = predictions_table.user_id").
        select("prediction_users.id, full_name, calculated_count, all_predictions_count, total_point").
        order("total_point desc, ISNULL(calculated_count), calculated_count asc, full_name asc")
    end
    
    # Shows rules
    def rules
    end
    
    private
      # Fetch matches from parameters else first competetion
      def fetch_matches
        if params[:id].present?
          @phase = Phase.find_by_id(params[:id])
          @competetion = @phase.competetion if @phase
        else
          @competetion = Competetion.first
          @phase = @competetion.phases.current_phase.try(:first) if @competetion
        end
        if @phase
          @matches = @phase.matches.order(:match_time).includes(:home_team, :away_team, :user_predictions)
          @count = UserPrediction.where(match_id: @matches.pluck(:id)).group(:match_id).count(:id)
        end
      end
      
      # User prediction parameters
      def prediction_params
        params.require(:prediction).permit(:match_id, :home_team_score, :away_team_score)
      end
  end
end
