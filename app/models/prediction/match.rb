module Prediction
  class Match < ApplicationRecord
    belongs_to :competetion
    belongs_to :phase
    belongs_to :home_team, foreign_key: :home_team_id, class_name: "Team"
    belongs_to :away_team, foreign_key: :away_team_id, class_name: "Team"
    has_many :user_predictions, dependent: :destroy
    validates_presence_of :match_time
    validates :home_team_score, :away_team_score, numericality: { only_integer: true }, if: Proc.new{|m| (m.home_team_score || m.away_team_score)}
    after_save :update_phase_status, if: Proc.new{|m| m.match_ended_changed?}
    after_save :update_competetion_dates, if: Proc.new{|m| m.match_time_changed?}
    after_save :update_phase_dates, if: Proc.new{|m| m.match_time_changed?}
    after_save :update_phase_matches_count
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
      return Time.now.in_time_zone("Chennai") <= (match_time.in_time_zone("Chennai") - 90.minutes)
    end
    
    # Calculate predictions of a match
    def calculate_scores_for_predictions
      return false unless match.match_ended
      predictions = user_predictions.uncalculated_predictions
      predictions.each do |prediction|
        predictions.calculat_score
      end
    end
    
    private
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
  end
end
