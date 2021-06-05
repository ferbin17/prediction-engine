require "prediction/version"
require "prediction/engine"

module Prediction
  def self.create_copa_group_stage_data
    competetion = Competetion.find_or_create_by(name: "Copa America 2021")
    
    teams = [{name: "Brazil", short_name: "BRA"}, {name: "Colombia", short_name: "COL"},
      {name: "Ecuador", short_name: "ECA"}, {name: "Peru", short_name: "PER"},
      {name: "Venezuela", short_name: "VEN"}, {name: "Argentina", short_name: "ARG"},
      {name: "Bolivia", short_name: "BOL"}, {name: "Chile", short_name: "CHI"},
      {name: "Paraguay", short_name: "PAR"}, {name: "Uruguay", short_name: "URU"}]
    teams.each do |team|
      instance_variable_set("@#{team[:name].downcase}", competetion.teams.build(team))
    end
    
    phases = [{name: "Match Day 1", order: 1}, {name: "Match Day 2", order: 2},
      {name: "Match Day 3", order: 3}, {name: "Match Day 4", order: 4},
      {name: "Match Day 5", order: 5}, {name: "Quarter Final", order: 6},
      {name: "Semi Final", order: 7}, {name: "Lose's Final", order: 8},
      {name: "Final", order: 9}]
    phases.each do |phase|
      instance_variable_set("@phase#{phase[:order]}", competetion.phases.build(phase))
    end
    competetion.save
    
    Time.zone = ActiveSupport::TimeZone.new('Chennai')
    phase_matches = {1 => [{home_team_id: instance_variable_get("@#{"Brazil".downcase}").id, away_team_id: instance_variable_get("@#{"Venezuela".downcase}").id, match_time: Time.new(2021, 06, 14, 2, 30)},
      {home_team_id: instance_variable_get("@#{"Colombia".downcase}").id, away_team_id: instance_variable_get("@#{"Ecuador".downcase}").id, match_time: Time.new(2021, 06, 14, 5, 30)},
      {home_team_id: instance_variable_get("@#{"Argentina".downcase}").id, away_team_id: instance_variable_get("@#{"Chile".downcase}").id, match_time: Time.new(2021, 06, 15, 2, 30)},
      {home_team_id: instance_variable_get("@#{"Paraguay".downcase}").id, away_team_id: instance_variable_get("@#{"Bolivia".downcase}").id, match_time: Time.new(2021, 06, 15, 5, 30)}],
      2 => [{home_team_id: instance_variable_get("@#{"Colombia".downcase}").id, away_team_id: instance_variable_get("@#{"Venezuela".downcase}").id, match_time: Time.new(2021, 06, 18, 2, 30)},
      {home_team_id: instance_variable_get("@#{"Brazil".downcase}").id, away_team_id: instance_variable_get("@#{"Peru".downcase}").id, match_time: Time.new(2021, 06, 18, 5, 30)},
      {home_team_id: instance_variable_get("@#{"Chile".downcase}").id, away_team_id: instance_variable_get("@#{"Bolivia".downcase}").id, match_time: Time.new(2021, 06, 19, 2, 30)},
      {home_team_id: instance_variable_get("@#{"Argentina".downcase}").id, away_team_id: instance_variable_get("@#{"Uruguay".downcase}").id, match_time: Time.new(2021, 06, 19, 5, 30)}],
      3 => [{home_team_id: instance_variable_get("@#{"Venezuela".downcase}").id, away_team_id: instance_variable_get("@#{"Ecuador".downcase}").id, match_time: Time.new(2021, 06, 21, 2, 30)},
      {home_team_id: instance_variable_get("@#{"Colombia".downcase}").id, away_team_id: instance_variable_get("@#{"Peru".downcase}").id, match_time: Time.new(2021, 06, 21, 5, 30)},
      {home_team_id: instance_variable_get("@#{"Uruguay".downcase}").id, away_team_id: instance_variable_get("@#{"Chile".downcase}").id, match_time: Time.new(2021, 06, 22, 2, 30)},
      {home_team_id: instance_variable_get("@#{"Argentina".downcase}").id, away_team_id: instance_variable_get("@#{"Paraguay".downcase}").id, match_time: Time.new(2021, 06, 22, 5, 30)}],
      4 => [{home_team_id: instance_variable_get("@#{"Ecuador".downcase}").id, away_team_id: instance_variable_get("@#{"Peru".downcase}").id, match_time: Time.new(2021, 06, 24, 2, 30)},
      {home_team_id: instance_variable_get("@#{"Brazil".downcase}").id, away_team_id: instance_variable_get("@#{"Colombia".downcase}").id, match_time: Time.new(2021, 06, 24, 5, 30)},
      {home_team_id: instance_variable_get("@#{"Bolivia".downcase}").id, away_team_id: instance_variable_get("@#{"Uruguay".downcase}").id, match_time: Time.new(2021, 06, 25, 2, 30)},
      {home_team_id: instance_variable_get("@#{"Chile".downcase}").id, away_team_id: instance_variable_get("@#{"Paraguay".downcase}").id, match_time: Time.new(2021, 06, 25, 5, 30)}],
      5 => [{home_team_id: instance_variable_get("@#{"Brazil".downcase}").id, away_team_id: instance_variable_get("@#{"Ecuador".downcase}").id, match_time: Time.new(2021, 06, 28, 2, 30)},
      {home_team_id: instance_variable_get("@#{"Venezuela".downcase}").id, away_team_id: instance_variable_get("@#{"Peru".downcase}").id, match_time: Time.new(2021, 06, 28, 5, 30)},
      {home_team_id: instance_variable_get("@#{"Uruguay".downcase}").id, away_team_id: instance_variable_get("@#{"Paraguay".downcase}").id, match_time: Time.new(2021, 06, 29, 2, 30)},
      {home_team_id: instance_variable_get("@#{"Bolivia".downcase}").id, away_team_id: instance_variable_get("@#{"Argentina".downcase}").id, match_time: Time.new(2021, 06, 29, 5, 30)}]}
    phase_matches.each do |phase_no, matches|
      phase = instance_variable_get("@phase#{phase_no}")
      matches.each do |match|
        phase.matches.build(match.merge(competetion_id: competetion.id))
      end
      phase.setup_completed = true
      phase.save
    end

  end
  
  def self.clear_copa_data
    Competetion.destroy_all
  end
end
