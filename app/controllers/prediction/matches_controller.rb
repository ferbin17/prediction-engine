require_dependency "prediction/application_controller"

module Prediction
  class MatchesController < ApplicationController
    before_action :check_admin_permission, except: [:predictions]
    before_action :find_phase, only: [:new, :create]
    before_action :find_match, only: [:edit, :update, :destroy, :confirm_match, :predictions]
    before_action :find_active_match, only: [:end_match, :submit_score, :calculate_score]
    
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
        @match.update(is_active: false)
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
    def end_match
      if @match.end_match
        flash.now[:success] = t(:match_marked_as_ended)
      else
        @errors = @match.errors.full_messages
        @match.reload
      end
    end
    
    # Submits the match score
    def submit_score
      if request.patch?
        if @match.submit_score(match_params[:home_team_score], match_params[:away_team_score])
          flash.now[:success] = t(:score_submitted_success)
        else
          @errors = @match.errors
        end
      end
    end
    
    # calculate prediction score for a match
    def calculate_score
      if @match.calculate_scores_for_predictions
        flash.now[:success] = t(:prediction_score_calculated)
      else
        @errors = @match.errors
      end
    end
    
    # Shows the predictions of a match
    def predictions
      redirect_if_deadline_not_over
      @user_predictions = @match.user_predictions.includes(:user).includes(match: [:home_team, :away_team])
      @competetion = @match.competetion
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
        @match = Match.not_deleted.includes(:home_team, :away_team).find_by_id(params[:id])
        unless @match
          if request.xhr?
            flash.now[:danger] = t(:match_not_found)
            render head: :ok
          else
            flash[:danger] = t(:match_not_found)
            redirect_to settings_path
          end
        end
      end
      
      # Finds active match from parameters
      def find_active_match
        @match = Match.includes(:home_team, :away_team).find_by_id(params[:id])
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
      
      # Redirect if match is deadline not over
      def redirect_if_deadline_not_over
        unless @match.deadline <= Time.now
          flash[:warning] = t(:match_deadline_is_not_over)
          redirect_to root_path
        end
      end
            
  end
end
