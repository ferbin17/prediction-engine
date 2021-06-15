module Prediction
  class Match < ApplicationRecord
    default_scope -> { where(is_active: true, is_deleted: false) } 
    belongs_to :competetion
    belongs_to :phase
    belongs_to :home_team, foreign_key: :home_team_id, class_name: "Team"
    belongs_to :away_team, foreign_key: :away_team_id, class_name: "Team"
    has_many :user_predictions, dependent: :destroy
    validates_presence_of :match_time
    validates :home_team_score, :away_team_score, numericality: { only_integer: true }, if: Proc.new{|m| (m.home_team_score || m.away_team_score)}
    validate :same_teams, if: Proc.new{|m| m.home_team && m.away_team}
    validate :validate_match_ended_value, if: Proc.new{|m| m.match_ended_changed? && m.match_ended}
    after_save :update_phase_status, if: Proc.new{|m| m.match_ended}
    after_save :update_competetion_dates, if: Proc.new{|m| m.match_time}
    after_save :update_phase_dates, if: Proc.new{|m| m.match_time}
    after_save :update_phase_matches_count
    scope :active, -> { where(is_active: true) }
    scope :not_deleted, -> { unscoped.where(is_deleted: false)}
    scope :finished_matches, -> { where(match_ended: true) }
    scope :unfinished_matches, -> { where(match_ended: false) }
    
    # Display name of match
    def full_name
      "#{home_team.full_name} vs #{away_team.full_name}"
    end
    
    # Return deadline of match
    def deadline
      (match_time - 90.minutes)
    end
    
    # Check if deadline is over
    def can_edit?
      return Time.now <= deadline
    end
    
    # Calculate predictions of a match
    def calculate_scores_for_predictions
      return false unless match_ended && score_submitted
      predictions = user_predictions.uncalculated_predictions
      predictions.each do |prediction|
        prediction.calculate_score
      end
      self.update(score_calculated: true)
    end
    
    # Mark match as ended
    def end_match
      self.update(match_ended: true)
    end
    
    # Submit the score of a match
    def submit_score(home_score, away_score)
      if match_ended
        if self.update(home_team_score: home_score, away_team_score: away_score, score_submitted: true)
          update_score_calculated_status
          return true
        end
      else
        errors.add(:home_team_score, :cant_submit_score_before_match_is_finished)
      end
      return false
    end
    
    private
      # Validate if hoem and away team are same
      def same_teams
        errors.add(:home_team, :home_and_away_same) if home_team == away_team
      end
      
      # Update number of matches
      def update_phase_matches_count
        phase.update(no_of_matches: phase.matches.count)
      end
      
      # Mark the phase as completed if all matches are played
      def update_phase_status
        left_matches = phase.matches.unfinished_matches
        unless left_matches.present?
          phase.update(phase_completed: true)
        end
      end
      
      # Update competetion start and end date whenever a new match is updated
      def update_competetion_dates
        first_match_time = competetion.matches.order(:match_time).limit(1).pluck(:match_time).first
        last_match_time = competetion.matches.order(match_time: :desc).limit(1).pluck(:match_time).first
        competetion.update(start_datetime: first_match_time, end_datetime: last_match_time)
      end
      
      # Update phase start and end date whenever a new match is updated
      def update_phase_dates
        first_match_time = phase.matches.order(:match_time).limit(1).pluck(:match_time).first
        last_match_time = phase.matches.order(match_time: :desc).limit(1).pluck(:match_time).first
        competetion.update(start_datetime: first_match_time, end_datetime: last_match_time)
      end
      
      # Check if match can be ended
      def validate_match_ended_value
        unless (match_time + 120.minutes) <= Time.now
          errors.add(:match_ended, :match_cant_be_ended_before_match_time)
        end
      end
      
      # Update score caculated status incase of score resubmission
      def update_score_calculated_status
        predictions = user_predictions.calculated_predictions
        predictions.update_all(point_calculated: false)
        self.update(score_calculated: false)
      end
  end
end
