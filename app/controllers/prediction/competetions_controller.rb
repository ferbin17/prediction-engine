require_dependency "prediction/application_controller"

module Prediction
  class CompetetionsController < ApplicationController
    before_action :check_admin_permission
    before_action :find_competetion, only: [:edit, :update, :destroy, :show, 
      :confirm_competetion]
    
    # Competetion creation popup
    def new
      @competetion = Competetion.new    
    end
    
    # Creates new competetion
    def create
      @competetion = Competetion.new(competetion_params.merge({is_active: false}))
      if @competetion.save
        @competetion.update(is_active: false)
        flash.now[:success] = t(:competetion_created)
      else
        @errors = @competetion.errors.instance_variable_get("@errors")
      end
    end
    
    # Competetion updation popup
    def edit
    end
    
    # Updates the competetion
    def update
      if @competetion.update(competetion_params)
        flash.now[:success] = t(:competetion_updated)
      else
        @errors = @competetion.errors.instance_variable_get("@errors")
      end
    end
    
    # Destroys the competetion
    def destroy
      flash.now[:success] = t(:competetion_deleted) if @competetion.update(is_deleted: true)
    end
    
    # Changes the current active status of competetion
    def confirm_competetion
      if @competetion.update(is_active: !@competetion.is_active)
        action = t((@competetion.is_active ? 'activate' : 'deactivate'))
        flash.now[:success] = t(:competetion_changed, action:  action)
      end
    end
    
    # Show the phases of competetion
    def show
      @phases = @competetion.phases.not_deleted.includes(matches: [:home_team, :away_team])
    end
    
    private
      # Competetion parameters
      def competetion_params
        params.require(:competetion).permit(:name, :no_of_teams, :no_of_phases)
      end
      
      # Find the competetion from parameters
      def find_competetion
        @competetion = Competetion.not_deleted.find_by_id(params[:id])
        unless @competetion
          if request.xhr?
            flash.now[:danger] = t(:competetion_not_found)
            render head: :ok
          else
            flash[:danger] = t(:competetion_not_found)
            redirect_to settings_path
          end
        end
      end
  end
end
