module Prediction
  class Team < ApplicationRecord
    default_scope -> { where(is_active: true, is_deleted: false) } 
    belongs_to :competetion
    validates_presence_of :name, :short_name
    after_save :update_competetion_teams
    scope :active, -> { where(is_active: true) }
    scope :not_deleted, -> { unscoped.where(is_deleted: false)}
    
    # Display name for a team
    def full_name
      "#{name} (#{short_name})"
    end
    
    private
      # Update team count of competetion
      def update_competetion_teams
        competetion.update(no_of_teams: competetion.teams.count)
      end
  end
end
