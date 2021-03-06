class Player < ActiveRecord::Base
  validates_presence_of :first_name, :last_name
  
  belongs_to :nhl_team
  
  has_many :draft_picks
  has_many :stats
  has_many :games, :through => :stats
  has_many :roster_assignments
  has_many :fantasy_teams, :through => :roster_assignments
  has_many :starts
  has_many :position_assignments
  has_many :positions, :through => :position_assignments
  has_many :moves

  has_attached_file :photo,
    :default_url => "players/missing.jpg",
    :styles => {
      :thumb => "40x40#",
      :small  => "150x150>" }

  
  named_scope :skaters,
              :include => :positions, 
              :conditions => [ 'positions.name != ?', 'Goalie' ]
  
  named_scope :forwards,
              :include => :positions, 
              :conditions => [ 'positions.name != ? AND positions.name != ?', 'Goalie', 'Defense' ]
  
  named_scope :wings,
              :include => :positions, 
              :conditions => [ 'positions.name = ? OR positions.name = ?', 'Right Wing', 'Left Wing' ]
  
  named_scope :centers,
              :include => :positions, 
              :conditions => { 'positions.name' => 'Center' }
            
  named_scope :right_wings,
              :include => :positions, 
              :conditions => { 'positions.name' => 'Right Wing' }
  
  named_scope :left_wings,
              :include => :positions, 
              :conditions => { 'positions.name' => 'Left Wing' }
  
  named_scope :defensemen,
              :include => :positions, 
              :conditions => { 'positions.name' => 'Defense' }
  
  named_scope :goalies,
              :include => :positions, 
              :conditions => { 'positions.name' => 'Goalie' }
  
  
  def self.unavailable_in_league(league_name)
    Player.find(:all,
      :include    => [:fantasy_teams => :league],
      :conditions => {'leagues.name' => league_name}
    )
  end

  def self.available_in_league(league_name)
    Player.find(:all,
      :include    => [:nhl_team, :positions, {:fantasy_teams => {:fantasy_seasons => :league} }],
      :conditions => ["leagues.name IS NULL OR leagues.name != ?", league_name]
    )
  end

  def self.unavailable_in_fantasy_season(fantasy_season)
    Player.find(:all,
      :include    => [:nhl_team, :positions, {:fantasy_teams => :fantasy_seasons}],
      :conditions => ["fantasy_seasons.id = ?", fantasy_season.id]
    )
  end

  def self.available_in_fantasy_season(fantasy_season)
    Player.find(:all, :order => :yahoo_orank, :include => [:nhl_team, :positions]) - self.unavailable_in_fantasy_season(fantasy_season)
  end

  def owner_in_fantasy_season(fantasy_season=@current_fantasy_season)
    owned_by = fantasy_teams.find(:all,
      :include    => :fantasy_seasons,
      :conditions => ["fantasy_seasons.id = ?", fantasy_season.id]
    ).first.name rescue nil

    owned_by ||= 'FA'
  end
  
  def name
    "#{first_name} #{last_name}"
  end
  
  def position
    positions.first
  end
end
