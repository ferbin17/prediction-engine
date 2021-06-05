require_dependency "prediction/application_controller"
require_dependency "../services/prediction/prediction_creator"

module Prediction
  class PredictionsController < ApplicationController
    before_action :check_permission, except: [:table]
    
    def predict
      fetch_matches
      @user_predictions = @current_user.user_predictions_in_phase(@phase.id) if @phase
      if request.post?
        @errors = PredictionCreator.call(@current_user, prediction_params)
        flash[:success] = (@errors.empty? ? t(:prediction_saved) : nil)
        @match = Match.find_by_id(prediction_params[:match_id])
        @prediction = @current_user.user_predictions.find_by_match_id(prediction_params[:match_id])
        respond_to :js
      end
    end
    
    def match_popup
      @match = Match.find_by_id(params[:id])
      if @match
        @phase = @match.phase
        @prediction = @current_user.user_predictions.where(match_id: @match.id).first
      end
    end
    
    def table
      @users = User.players.left_joins(:user_predictions).select(:full_name, :total_point).group(:id).order('total_point DESC, COUNT(prediction_user_predictions.id) ASC')
    end
    
    private
      def fetch_matches
        if params[:id].present?
          @phase = Phase.find_by_id(params[:id])
          @competetion = @phase.competetion
        else
          @competetion = Competetion.active.first
          @phase = @competetion.phases.current_phase.try(:first)
        end
        @matches = @phase.matches.order(:match_time).includes(:home_team, :away_team, :user_predictions) if @phase
      end
      
      def prediction_params
        params.require(:prediction).permit(:match_id, :home_team_score, :away_team_score)
      end
      
      def check_permission
        redirect_to settings_path if @current_user.is_admin?
      end
  end
end
