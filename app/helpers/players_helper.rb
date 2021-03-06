module PlayersHelper
  def owned_by(player)
    owned_by = player.fantasy_teams.find(:all,
      :include    => :fantasy_seasons,
      :conditions => ["fantasy_seasons.id = ?", @current_fantasy_season]
    ).first.name rescue nil

    owned_by ||= 'FA'
  end
  
  def display_rank(rank)
    rank == 99999 ? 'NA' : rank
  end
end
