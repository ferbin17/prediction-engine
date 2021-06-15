module Prediction
  class ApplicationController < ActionController::Base
    before_action :require_login
    before_action :check_for_first_login
    helper_method :current_user
    helper_method :check_admin_permission
    helper_method :check_player_permission
    
    private
      # Set current_user value and redirect to login page if current user is nil
      def require_login
        current_user
        redirect_to login_users_path unless @current_user
      end
      
      # Check if the its user's first login
      def check_for_first_login
        if @current_user && @current_user.first_login
          redirect_to change_password_user_path(@current_user)
        end
      end

      # Set current_user value
      def current_user
        @current_user ||= User.find_by_id(current_user_id)
      end
      
      # Creates JWT token
      def jwt_token(user_id)
        payload = {user_id: user_id}        
        JWT.encode(payload, hmac_secret, 'HS256')
      end
      
      # Fetch current_user_id from JWT if exists
      def current_user_id
        begin
          session[:jwt_token] ||= cookies.encrypted[:jwt_token]
          decoded_array = JWT.decode(session[:jwt_token], hmac_secret, true, {algorithm: 'HS256'})
          payload = decoded_array.first
        rescue #JWT::VerificationError
          return nil
        end
        payload["user_id"]
      end
      
      # Key for JWT encoding
      def hmac_secret
        Rails.application.credentials.jwt_encryption[:key]
      end
      
      # Check if the user is admin else redirects to root
      def check_admin_permission
        redirect_to root_path unless @current_user.is_admin?
      end
      
      # Check if the user is player else redirects to settings
      def check_player_permission
        redirect_to settings_path if @current_user.is_admin?
      end
  end
end
