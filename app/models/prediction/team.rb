module Prediction
  class Team < ApplicationRecord
    belongs_to :competetion
    validates_presence_of :name, :short_name
    after_save :update_competetion_teams
    
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
