require_dependency "prediction/application_controller"

module Prediction
  class UsersController < ApplicationController
    skip_before_action :require_login, only: [:login, :new, :create]
    skip_before_action :check_for_first_login, only: [:change_password, :logout]
    before_action :check_logined_user, only: [:login, :new, :create] 
    before_action :check_admin_permission, only: [:index, :login_requests, :approval,
      :destroy, :reset_password]
    before_action :find_user, only: [:destroy, :show, :reset_password, :predictions]
    
    # Login page and authentication
    def login
      @user = User.new
      fetch_user_from_cookie
      if request.post?
        @user = User.new(login_params)
        if @user.authenticate
          find_user_and_set_token
          redirect_to root_path  
        else
          flash[:danger] = t(:wrong_crendials)
        end
      end
    end
    
    # Logout
    def logout
      session.delete(:jwt_token)
      cookies.delete(:jwt_token)
      redirect_to root_path
    end
    
    # Change password page
    def change_password
      @user = User.new
      if request.post?
        @user = User.new(username: @current_user.username, password: change_password_params[:password])
        if @user.authenticate
          password_match = @current_user.update_default_password(change_password_params)
          if password_match == true
            flash[:success] = t(:password_changed_successfully)
            redirect_to profile_user_path(@current_user)
          elsif password_match == ""
            flash[:danger] = t(:new_password_different_from_current_password)
          else
            flash[:danger] = t(:new_passwords_didnt_match)
          end
        else
          flash[:danger] = t(:wrong_password)
        end
      end
    end
    
    # Login request list
    def login_requests
      @users = User.not_deleted.players.login_requested
    end
    
    # approves the login request
    def approval
      check_for_any_login_request
      if request.post?
        @user = User.not_deleted.players.login_requested.find_by_request_token(player_approval_params[:request_token])
        if @user
          if player_approval_params[:approval]
            if @user.update(request_token: nil, first_login: false) && @user.toggle_active_status
              flash[:success] = t(:player_login_approved)
              redirect_to approval_users_path
            else
              @errors = @user.errors.full_messages
            end
          end
        else
          flash.now[:warning] = t(:no_player_found_at_request_token, token: player_approval_params[:request_token])
        end
      end
    end
    
    # Index
    def index
      @users = User.not_deleted.active
    end
    
    # Login request page
    def new
      @request_token = cookies.encrypted[:request_token]
      flash[:warning] = t(:request_token_already_generated, token: @request_token) if @request_token
      @user = User.new
    end
    
    # Creates a login request/Inactive User
    def create
      @user = User.new(user_params)
      if @user.save
        @user.toggle_active_status
        cookies.encrypted[:request_token] = @user.generate_request_token
        flash[:success] = t(:request_token_generated, token: cookies.encrypted[:request_token])
        redirect_to root_path
      else
        render action: :new
        @errors = @user.errors.full_messages
      end
    end
    
    # Edit user
    def edit
      @user = (@current_user.is_admin? ? User.find_by_id(params[:id]) : @current_user)
    end
    
    # Update user
    def update
      @user = (@current_user.is_admin? ? User.find_by_id(params[:id]) : @current_user)
      @new_user = User.new(username: @user.username, password: user_params[:password])
      @user.assign_attributes(user_params)
      if @current_user.is_admin? || @new_user.authenticate
        if @user.save
          flash[:success] = t(:user_details_saved)
          if @current_user.is_admin?
            redirect_to user_path(@user)
          else
            redirect_to profile_user_path(@user)
          end
        else
          @errors = @user.errors.full_messages
          render action: :edit
        end
      else
        flash[:danger] = t(:wrong_password)
        render action: :edit
      end
    end
    
    # Deletes the user
    def destroy
      if @user
        if @user.delete_user
          flash[:success] = t(:user_deleted)
        else
          flash[:danger] = t(:something_went_wrong)
        end
      else
        flash[:danger] = t(:user_not_found)
      end
      redirect_back(fallback_location: users_path)
    end
    
    # Show user details
    def show
    end
    
    # User profile
    def profile
      @user = @current_user
    end
    
    # Resets password if admin
    def reset_password
      if @user
        if @user.reset_password
          flash[:success] = t(:password_reseted)
        else
          flash[:danger] = t(:something_went_wrong)
        end
      else
        flash[:danger] = t(:user_not_found)
      end
      redirect_back(fallback_location: users_path)
    end
    
    # Shows the predictions of a user
    def predictions
      fetch_matches
      @user_predictions = @user.user_locked_predictions_in_phase(@phase.id) if @phase
    end
    
    private
      # User parameters
      def user_params
        params.require(:user).permit(:full_name, :username, :password, :phone_no, :id)
      end
      
      # Login parameters
      def login_params
        params.require(:user).permit(:username, :password)
      end
      
      # Remember me parameters
      def remember_me_param
        params.require(:user).permit(:remember_me)
      end
      
      # Change password parameters
      def change_password_params
        params.require(:user).permit(:password, :new_password, :confirm_password)
      end
      
      # Login approval parameters
      def player_approval_params
        params.require(:user).permit(:full_name, :phone_no, :request_token, :approval)
      end
      
      # Find user and store jwt token in session 
      def find_user_and_set_token
        user = User.find_by_username(login_params[:username])
        session[:jwt_token] = jwt_token(user.id)
        flash[:success] = t(:welcome_user, name: user.full_name)
        cookies.encrypted[:jwt_token] = session[:jwt_token] if remember_me_param[:remember_me] == "1"
      end
      
      # Redirect to root if user is already logined
      def check_logined_user
        redirect_to root_path if current_user
      end
      
      # Fetch user if there is any cookie for site in browser
      def fetch_user_from_cookie
        if cookies.encrypted[:jwt_token]
          decoded_array = JWT.decode(cookies.encrypted[:jwt_token], hmac_secret, true, {algorithm: 'HS256'})
          payload = decoded_array.first
          @user = User.select(:username).find_by_id(payload["user_id"])
        end     
      end
      
      # Redirect to settngs if not login request
      def check_for_any_login_request
        redirect_to settings_path unless User.not_deleted.players.login_requested.count > 0
      end
      
      # Find user
      def find_user
        @user = User.find_by_id(params[:id])
        unless @user
          flast[:danger] = t(:user_not_found)
          redirect_to root_path
        end
      end
      
      # Fetch matches from parameters else first competetion
      def fetch_matches
        if params[:p_id].present?
          @phase = Phase.find_by_id(params[:p_id])
          @competetion = @phase.competetion if @phase
        else
          @competetion = Competetion.first
          @phase = @competetion.phases.current_phase.try(:first) if @competetion
        end
        if @phase
          @matches = @phase.matches.order(:match_time).includes(:home_team, :away_team, :user_predictions)
        end
      end
  end
end
