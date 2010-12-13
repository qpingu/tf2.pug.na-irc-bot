require './util.rb'

class Team
  include Utilities
  
  attr_accessor :captain, :players
	attr_accessor :name, :colour
  
  def initialize captain, details
    @captain = captain
		@players = { captain => "captain" }
    
    @name = details["name"]
    @colour = details["colour"]
	end

  def get_classes
    @players.invert_proper
  end
  
  def my_colourize msg, bg = const["colours"]["black"]
    colourize msg, @colour, bg
  end
  
  def output_team
    output = players.collect { |k, v| "#{ k } as #{ my_colourize v }" }
    "#{ my_colourize @name }: #{ output.values.join(", ") if output }"
  end

  def to_s
    @name
  end
end
