module Prediction
  class ApplicationController < ActionController::Base
    before_action :require_login
    before_action :check_for_first_login
    helper_method :current_user
    
    private
      def require_login
        current_user
        redirect_to login_users_path unless @current_user
      end
      
      def check_for_first_login
        if @current_user && @current_user.first_login
          redirect_to change_password_users_path
        end
      end

      
      def current_user
        @current_user ||= User.find_by_id(current_user_id)
      end
      
      def jwt_token(user_id)
        payload = {user_id: user_id}        
        JWT.encode(payload, hmac_secret, 'HS256')
      end
      
      def current_user_id
        begin
          # session[:jwt_token] ||= cookies.encrypted[:jwt_token]
          decoded_array = JWT.decode(session[:jwt_token], hmac_secret, true, {algorithm: 'HS256'})
          payload = decoded_array.first
        rescue #JWT::VerificationError
          return nil
        end
        payload["user_id"]
      end
      
      def hmac_secret
        Rails.application.credentials.jwt_encryption[:key]
      end
  end
end
