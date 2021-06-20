require_dependency "prediction/application_controller"

module Prediction
  class PhasesController < ApplicationController
    before_action :check_admin_permission
    before_action :find_competetion, only: [:new, :create]
    before_action :find_phase, only: [:edit, :update, :destroy, :show,
      :confirm_phase]
    
    # New phase popup
    def new
      @phase = @competetion.phases.build
      @next_order = @competetion.phases.pluck(:order).sort.last + 1
    end
    
    # Create new phase
    def create
      @phase = @competetion.phases.build(phase_params)
      if @competetion.save
        @phase.update(is_active: false)
        flash.now[:success] = t(:phase_created)
      else
        @errors = @phase.errors.instance_variable_get("@errors")
      end
    end
    
    # Edit phase popup
    def edit
    end
    
    # Updates phase
    def update
      if @phase.update(phase_params)
        flash.now[:success] = t(:phase_updated)
      else
        @errors = @phase.errors.instance_variable_get("@errors")
      end
    end
    
    # Delete the phase
    def destroy
      flash.now[:success] = t(:phase_deleted) if @phase.update(is_deleted: true)
    end
    
    # Change active status
    def confirm_phase
      if @phase.update(is_active: !@phase.is_active)
        action = t((@phase.is_active ? 'activate' : 'deactivate'))
        flash.now[:success] = t(:phase_changed, action:  action)
      end
    end
    
    # Shows matches of the phase
    def show
      @matches = @phase.matches.not_deleted.includes(:home_team, :away_team)
    end
    
    private
      # Phase parameters 
      def phase_params
        params.require(:phase).permit(:name, :order, :no_of_matches, :phase_completed, :competetion_id)
      end
      
      # Finds the competetion from parameters
      def find_competetion
        @competetion = Competetion.not_deleted.find_by_id(params[:id]||phase_params[:competetion_id])
        unless @competetion
          flash.now[:danger] = t(:competetion_not_found)
          render head: :ok
        end
      end
      
      # Finds the phase from parameters
      def find_phase
        @phase = Phase.not_deleted.find_by_id(params[:id])
        unless @phase
          if request.xhr?
            flash.now[:danger] = t(:phase_not_found)
            render head: :ok
          else
            flash[:danger] = t(:phase_not_found)
            redirect_to settings_path
          end
        end
      end
  end
end
