module StateLogic
  def attempt_afk
    if @state == Const::State_waiting and minimum_players?
      @state = Const::State_afk
      
      message "Checking for afk players, please wait."
      
      @afk = check_afk @players.keys # will take a long time
      start_afk unless @afk.empty?
      
      attempt_picking
    end
  end
  
  def attempt_picking
    if minimum_players?
      start_delay # pause for x seconds
      start_picking
    else
      @state = Const::State_waiting
    end
  end
  
  def check_afk list
    list.reject do |user|
      user.refresh
      !user.unknown? and user.idle <= Const::Afk_threshold # user is found and not idle
    end
  end

  def start_afk
    message "The following players are considered afk: #{ @afk.join(", ") }"
    
    @afk.each do |p|
      private p, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ Const::Afk_delay } seconds to avoid being removed."
    end
    
    sleep Const::Afk_delay

    # check again if users are afk, this time removing the ones who are
    check_afk(@afk).each { |user| @players.delete user }
    @afk.clear

    list_players # playersLogic.rb
  end
  
  def start_delay
    @state = Const::State_delay
    
    message "Teams are being drafted, captains will be selected in #{ Const::Picking_delay } seconds"
    sleep Const::Picking_delay
  end
  
  def start_picking
    @state = Const::State_picking
    
    update_lookup # pickingLogic.rb
    choose_captains # pickingLogic.rb
    tell_captain # pickingLogic.rb
  end
  
  def end_game
    @teams.clear
    @lookup.clear

    @state = Const::State_waiting
    @pick = 0
    
    next_server
    next_map
  end
  
  def picking? 
    @state == Const::State_picking
  end

  def can_add?
    @state < Const::State_picking
  end
  
  def can_remove?
    @state < Const::State_picking
  end
end