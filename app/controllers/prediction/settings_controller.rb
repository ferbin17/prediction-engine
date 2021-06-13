require_dependency "prediction/application_controller"

module Prediction
  class SettingsController < ApplicationController
    before_action :check_admin_permission
    
    # Index
    def index
      @competetions = Competetion.unscoped.where(is_deleted: false).includes(phases: {matches: [:home_team, :away_team]})
      @login_request_count = User.not_deleted.players.login_requested.count
    end
    
    private
  end
end
