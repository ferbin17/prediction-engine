require_dependency "prediction/application_controller"

module Prediction
  class MatchesController < ApplicationController
    before_action :find_phase, only: [:new, :create]
    before_action :find_match, only: [:edit, :update, :destroy, :confirm_match]
    
    # New match popup
    def new
      @competetion = @phase.competetion
      @teams = @competetion.teams
      @match = @phase.matches.build(competetion: @competetion)
    end
    
    # Create new match
    def create
      @match = @phase.matches.build(match_params)
      if validate_date && @phase.save
        flash.now[:success] = t(:match_created)
      else
        @errors = @match.errors.instance_variable_get("@errors")
      end
    end
    
    # Edit match popup
    def edit
      @phase = @match.phase
      @competetion = @match.competetion
      @teams = @competetion.teams
    end
    
    # Updates the match
    def update
      if validate_date && @match.update(match_params)
        flash.now[:success] = t(:match_updated)
      else
        @errors = @match.errors.instance_variable_get("@errors")
      end
    end
    
    # Deletes the match
    def destroy
      flash.now[:success] = t(:match_deleted) if @match.update(is_deleted: true)
    end
    
    # Change active status
    def confirm_match
      if @match.update(is_active: !@match.is_active)
        action = t((@match.is_active ? 'activate' : 'deactivate'))
        flash.now[:success] = t(:match_changed, action:  action)
      end
    end
    
    # Marks the match as finished
    def mark_as_finished
    end
    
    # Submits the match score
    def submit_match_score
    end
    
    # calculate prediction score for a match
    def calculate_match_score
    end
    
    private
      # Fetch match parameters
      def match_params
        params.require(:match).permit(:name, :home_team_id, :home_team_score, :away_team_id,
          :away_team_score, :match_ended, :match_time, :phase_id, :competetion_id)
      end
      
      # Finds phase from parameters
      def find_phase
        @phase = Phase.not_deleted.find_by_id(params[:id]||match_params[:phase_id])
        unless @phase
          flash.now[:danger] = t(:phase_not_found)
          render head: :ok
        end
      end
      
      # Finds match from parameters
      def find_match
        @match = Match.not_deleted.find_by_id(params[:id])
        unless @match
          flash.now[:danger] = t(:match_not_found)
          render head: :ok
        end
      end
      
      # Validate if date is valid
      def validate_date
        date = "#{match_params["match_time(3i)"]}-#{match_params["match_time(2i)"]}-#{match_params["match_time(1i)"]}"
        time = "#{match_params["match_time(4i)"]}:#{match_params["match_time(5i)"]}"
        begin
          DateTime.parse("#{date} #{time}")
          return true
        rescue => e
          @match.errors.add(:match_time, :invalid_date_time)
          return false
        end
      end
            
  end
end
