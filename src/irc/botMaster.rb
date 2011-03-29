require 'cinch'

require_relative '../constants'
require_relative '../pug'
require_relative 'botManager'

class BotMaster < Cinch::Bot
  def initialize
    super
    
    configure do |c|
      c.server = Constants.irc['server']
      c.port = Constants.irc['port']
      c.nick = Constants.Constants.irc['nick']
      c.local_host = Constants.Constants.internet['local_host']
      
      c.channels = [ Constants.Constants.irc['channel'] ]
      c.plugins.plugins = [ Pug ]

      c.verbose = false
    end
    
    on :connect do 
      bot.msg Constants.Constants.irc['auth_serv'], "AUTH #{ Constants.Constants.irc['auth'] } #{ Constants.Constants.irc['auth_password'] }" if Constants.Constants.irc['auth']
    end

    BotManager.instance.add self
  end
end
