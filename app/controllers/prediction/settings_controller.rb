require_dependency "prediction/application_controller"

module Prediction
  class SettingsController < ApplicationController
    before_action :check_permission
    before_action :find_competetion, only: [:edit_competetion, :delete_competetion,
      :change_competetion_status, :create_phase]
    before_action :find_phase, only: [:edit_phase, :delete_phase, :confirm_phase,
      :create_match, :calculate_phase_score]
    before_action :find_match, only: [:edit_match, :delete_match, :submit_match_score,
      :calculate_match_score]
        
    def index
      @competetions = Competetion.where(is_deleted: false).includes(phases: [:matches])
    end
    
    def create_competetion
      @competetion = Competetion.new
      if request.post?
        @competetion = Competetion.new(competetion_params)
        unless @competetion.save
          @errors = @competetion.errors.full_messages
        end
      end
    end
    
    def edit_competetion
      if request.post? && @competetion
        unless @competetion.update(competetion_params)
          @errors = @competetion.errors.full_messages
        end
      end
    end
    
    def delete_competetion
      @competetion.update(is_deleted: true) if @competetion
    end
    
    def change_competetion_status
      @competetion.update(is_active: !@competetion.is_active) if @competetion
    end
    
    def create_phase
      @phase = @competetion.phases.build if @competetion
      if request.post?
        @phase = @competetion.phases.build(phase_params)
        unless @competetion.save
          @errors = @competetion.errors.full_messages
        end
      end
    end
    
    def edit_phase
      if request.post? && @phase
        unless @phase.update(competetion_params)
          @errors = @phase.errors.full_messages
        end
      end
    end
    
    def delete_phase
      @phase.destory if @phase
    end
    
    def confirm_phase
      @phase.update(setup_completed: !@phase.setup_completed) if @phase
    end
    
    def calculate_phase_score
    end
    
    def create_match
      @match = @phase.matches.build if @phase
      if request.post?
        @match = @phase.matches.build(match_params)
        unless @phase.save
          @errors = @phase.errors.full_messages
        end
      end
    end
    
    def edit_match
    end
    
    def delete_match
    end
    
    def submit_match_score
    end
    
    def calculate_match_score
    end
    
    private
      def competetion_params
        params.require(:competetion).permit(:name, :no_of_teams, :no_of_phases)
      end
      
      def phase_params
        params.require(:phase).permit(:name, :order, :no_of_matches, :phase_completed)
      end
      
      def match_params
        params.require(:match).permit(:name, :home_team_id, :home_team_score, :away_team_id,
          :away_team_score, :match_ended, :match_time)
      end
      
      def find_competetion
        @competetion = Competetion.find_by_id(params[:id])
      end
      
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
      
      def check_permission
        redirect_to root_path unless @current_user.is_admin?
      end
  end
end
