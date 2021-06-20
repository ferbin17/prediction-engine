require_dependency "prediction/application_controller"

module Prediction
  class SettingsController < ApplicationController
    before_action :check_admin_permission
    
    # Index
    def index
      @competetions = Competetion.not_deleted.includes(phases: {matches: [:home_team, :away_team]})
      @login_request_count = User.not_deleted.players.login_requested.count
    end
    
    private
  end
end
