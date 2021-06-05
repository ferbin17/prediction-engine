require_dependency "prediction/application_controller"

module Prediction
  class UsersController < ApplicationController
    skip_before_action :require_login, only: [:login]
    skip_before_action :check_for_first_login, only: [:change_password]
    before_action :check_logined_user, only: [:login] 
    before_action :check_first_login_completed, only: [:change_password] 
    
    def login
      @user = User.new
      fetch_user_from_cookie
      if request.post?
        @user = User.new(user_params)
        if @user.authenticate
          find_user_and_set_token
          redirect_to root_path  
        else
          flash[:danger] = t(:wrong_crendials)
        end
      end
    end
    
    def logout
      session.delete(:jwt_token)
      # cookies.delete(:jwt_token)
      redirect_to root_path
    end
    
    def change_password
      @user = User.new
      if request.post?
        @user = User.new(username: @current_user.username, password: change_password_params[:password])
        if @user.authenticate
          if @current_user.update_default_password(change_password_params)
            flash[:success] = t(:password_changed_successfully)
            redirect_to root_path
          else
            flash[:danger] = t(:new_passwords_didnt_match)
          end
        else
          flash[:danger] = t(:wrong_password)
        end
      end
    end
    
    private
      def user_params
        params.require(:user).permit(:username, :password)
      end
      
      def remember_me_param
        params.require(:user).permit(:remember_me)
      end
      
      def change_password_params
        params.require(:user).permit(:password, :new_password, :confirm_password)
      end
      
      def find_user_and_set_token
        user = User.find_by_username(user_params[:username])
        session[:jwt_token] = jwt_token(user.id)
        flash[:success] = t(:welcome_user, name: user.full_name)
        cookies.encrypted[:jwt_token] = session[:jwt_token] if remember_me_param[:remember_me] == "1"
      end
      
      def check_logined_user
        redirect_to root_path if current_user
      end
      
      def check_first_login_completed
        redirect_to root_path unless current_user.first_login
      end
      
      def fetch_user_from_cookie
        if cookies.encrypted[:jwt_token]
          decoded_array = JWT.decode(cookies.encrypted[:jwt_token], hmac_secret, true, {algorithm: 'HS256'})
          payload = decoded_array.first
          @user = User.select(:username).find_by_id(payload["user_id"])
        end     
      end
  end
end
