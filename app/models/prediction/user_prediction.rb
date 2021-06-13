module Prediction
  class UserPrediction < ApplicationRecord
    default_scope -> { where(is_active: true, is_deleted: false) } 
    belongs_to :user
    belongs_to :match
    validates_presence_of :home_team_score, :away_team_score
    validates :home_team_score, :away_team_score, numericality: { only_integer: true }, if: Proc.new{|up| (up.home_team_score || up.away_team_score)}
    validates :match_id, uniqueness: {scope: [:user_id, :is_deleted]}
    validate :check_match_time, if: Proc.new{|up| (up.home_team_score_changed? || up.away_team_score_changed?)}
    scope :active, -> { where(is_active: true) }
    scope :not_deleted, -> { unscoped.where(is_deleted: false)}
    scope :calculated_predictions, -> { where(point_calculated: true) }
    scope :uncalculated_predictions, -> { where(point_calculated: false) }
    
    # Calcular score of user prediction
    def calculate_score
      return false unless match.match_ended && match.score_submitted
      home = (match.home_team_score == home_team_score)
      away = (match.away_team_score == away_team_score)
      score = ((home && away) ? 1 : 0)
      update(score: score, point_calculated: true)
      user.update_total_score
    end
    
    private
      # Check if modification is after deadline
      def check_match_time
        unless match.can_edit?
          errors.add(:base, :modification_not_allowed)
        end
      end
  end
end
