require_dependency "prediction/application_controller"

module Prediction
  class UsersController < ApplicationController
    skip_before_action :require_login, only: [:login, :new, :create]
    skip_before_action :check_for_first_login, only: [:change_password, :logout]
    before_action :check_logined_user, only: [:login, :new, :create] 
    before_action :check_first_login_completed, only: [:change_password]
    before_action :check_admin_permission, only: [:index, :approval]
    
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
      # cookies.delete(:jwt_token)
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
            redirect_to root_path
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
        @errors = @user.errors.full_messages
      end
    end
    
    # Index
    def index
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
    
    private
      # User parameters
      def user_params
        params.require(:user).permit(:full_name, :username, :password, :phone_no)
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
      
      # Redirect to root if not first login
      def check_first_login_completed
        redirect_to root_path unless current_user.first_login
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
  end
end
