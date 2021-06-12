module Prediction
  class Competetion < ApplicationRecord
    default_scope -> { where(is_active: true, is_deleted: false) } 
    has_many :phases, -> { order(:order) }, dependent: :destroy
    has_many :teams, dependent: :destroy
    validates_presence_of :name
    validates :name, uniqueness: {scope: :is_deleted}
    validates :no_of_phases, numericality: { only_integer: true }, if: Proc.new{|c| c.no_of_phases}
    validates :no_of_teams, numericality: { only_integer: true }, if: Proc.new{|c| c.no_of_teams}
    scope :active, -> { where(is_active: true) }
    scope :not_deleted, -> { unscoped.where(is_deleted: false)}
  end
end
