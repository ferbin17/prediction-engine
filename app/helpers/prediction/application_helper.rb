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
    
    def active_tab(params, link)
      if params[:controller] == "prediction/predictions"
        if params[:action] == link
          return "active"
        end
      elsif params[:controller] == "prediction/settings"
        if params[:action] == "index" && link == "settings"
          return "active"
        end
      end
    end
  end
end
