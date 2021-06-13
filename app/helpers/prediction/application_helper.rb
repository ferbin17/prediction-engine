module Prediction
  module ApplicationHelper
    
    def format_time(time, format = nil)
      case format
      when :datetime
        time.in_time_zone("Chennai").strftime("%d-%m-%Y %I:%M %p")
      else
        time.in_time_zone("Chennai")
      end
    end
    
    def active_tab(params, controller, link)
      if ["prediction/predictions"].include?(params[:controller]) && params[:controller] == "prediction/#{controller}"
        if params[:action] == link
          return "active"          
        end
      elsif params[:controller] == "prediction/settings" && params[:controller] == "prediction/#{controller}"
          if params[:action] == "index" && link == "settings"
          return "active"
        end
      elsif params[:controller] == "prediction/users" && params[:controller] == "prediction/#{controller}"
        if ["index", "approval", "login_requests"].include?(params[:action])
          return "active"
        elsif params[:controller] == "prediction/#{controller}" && params[:action] == link
          return "active"
        end
      end
    end
  end
end
