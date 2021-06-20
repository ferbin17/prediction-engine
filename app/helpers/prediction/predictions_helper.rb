module Prediction
  module PredictionsHelper
    
    def left_arrow_link(previous_phase)
      if previous_phase
        (link_to "&#8249;".html_safe, predict_predictions_path(id: previous_phase), class: "arrows previous round")
      else
        (link_to "&#8249;".html_safe, "#", class: "arrows previous round disabled-link")
      end
    end
    
    def right_arrow_link(next_phase)
      if next_phase
        (link_to "&#8250;".html_safe, predict_predictions_path(id: next_phase), class: "arrows next round")
      else
        (link_to "&#8250;".html_safe, "#", class: "arrows next round disabled-link")
      end
    end
    
    def left_arrow_user_link(user_id, previous_phase)
      if previous_phase
        (link_to "&#8249;".html_safe, predictions_user_path(id: user_id, p_id: previous_phase), class: "arrows previous round")
      else
        (link_to "&#8249;".html_safe, "#", class: "arrows previous round disabled-link")
      end
    end
    
    def right_arrow_user_link(user_id, next_phase)
      if next_phase
        (link_to "&#8250;".html_safe, predictions_user_path(id: user_id, p_id: next_phase), class: "arrows next round")
      else
        (link_to "&#8250;".html_safe, "#", class: "arrows next round disabled-link")
      end
    end
  end
end
