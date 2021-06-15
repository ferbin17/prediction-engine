module Prediction
  class Phase < ApplicationRecord
    default_scope -> { where(is_active: true, is_deleted: false) } 
    belongs_to :competetion
    has_many :matches, dependent: :destroy
    validates_presence_of :name, :order
    validates :order, numericality: { only_integer: true }, if: Proc.new{|p| p.order}
    validates :no_of_matches, numericality: { only_integer: true }, if: Proc.new{|p| p.no_of_matches}
    validates :name, uniqueness: {scope: [:competetion_id, :is_deleted]}
    validates :order, uniqueness: {scope: [:competetion_id, :is_deleted]}
    after_save :update_competetion_phases
    scope :active, -> { where(is_active: true) }
    scope :not_deleted, -> { unscoped.where(is_deleted: false)}
    scope :finished_phases, -> { where(phase_completed: true) }
    scope :unfinished_phases, -> { where(phase_completed: false) }
    scope :current_phase, -> { unfinished_phases.order(:order).limit(1) }
    
    # Returns previous phase id if present
    def previous_phase
      previous_phase = Phase.where("`order` < #{order}").order(order: :desc).limit(1).first
      previous_phase_id = previous_phase.id if previous_phase
      previous_phase_id
    end
    
    # Returns next phase id if present
    def next_phase
      next_phase = Phase.where("`order` > #{order}").order(:order).limit(1).first
      next_phase_id = next_phase.id if next_phase
      next_phase_id
    end
    
    # Calulate prediction scores for a phase
    def calculate_scores_for_predictoins
      return false unless phase_completed
      matches = matches.finished_matches
      matches.each do |match|
        match.calculate_scores_for_predictions
      end
    end
    
    private
      # Update phase count of competetion
      def update_competetion_phases
        competetion.update(no_of_phases: competetion.phases.count)
      end
  end
end
