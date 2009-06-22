class FantsayTeam < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  belongs_to :move
  
  has_many :starts
  has_many :roster_assignments
  has_many :players, :through => :roster_assignments
end
