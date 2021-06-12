require_dependency "prediction/application_controller"

module Prediction
  class SettingsController < ApplicationController
    before_action :check_admin_permission
    before_action :find_phase, only: [:edit_phase, :delete_phase, :confirm_phase,
      :create_match, :calculate_phase_score]
    before_action :find_match, only: [:edit_match, :delete_match, :submit_match_score,
      :calculate_match_score]
    
    # Index
    def index
      @competetions = Competetion.unscoped.where(is_deleted: false).includes(phases: [:matches])
      @login_request_count = User.not_deleted.players.login_requested.count
    end
    
    private      
      def find_phase
        @phase = Phase.find_by_id(params[:id])
        @competetion = @phase.competetion if @phase
      end
      
      def find_match
        @match = Match.find_by_id(params[:id])
        if @match
          @phase = @match.phase
          @competetion = @match.competetion
        end
      end
  end
end
