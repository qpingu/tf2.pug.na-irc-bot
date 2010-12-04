require 'socket'

module Summer
  class Connection
    attr_accessor :connection, :ready, :started, :config, :server, :port
    def initialize(server, port=6667, nick="TestBot", channel="#test.bot")
      @ready = false
      @started = false

      @server = server
      @port = port
      @nick = nick
      @channel = channel
    end
    
    def start
      connect!
      loop do
        startup! if @ready && !@started
        parse(@connection.gets)
        if @connection.eof?
          puts "Connection lost for message bot #{ @nick } Reconnecting in 60 seconds."
          sleep(60)
          @ready = false
          @started = false
          connect!
        end
      end

    end

    def msg(to, message)
      response("PRIVMSG #{to} :#{message}")
    end
    
    def notice(to, message)
      response("NOTICE #{to} :#{message}")
    end
	
    def started?
      @started
    end
    
    private
    def connect!
      @connection = TCPSocket.open(server, port)      
      response("USER #{@nick} #{@nick} #{@nick} #{@nick}")
      response("NICK #{@nick}")
    end


    # Will join channels specified in configuration.
    def startup!
      join(@channel)
      @started = true
    end

    # Go somewhere.
    def join(channel)
      response("JOIN #{channel}")
    end

    # Leave somewhere
    def part(channel)
      response("PART #{channel}")
    end

    # What did they say?
    def parse(message)
      words = message.split(" ")
      raw = words[1]
      # Handling pings
      if /^PING (.*?)\s$/.match(message)
        response("PONG #{$1}")
      # Handling raws
      elsif /\d+/.match(raw)
        send("handle_#{raw}", message) if raws_to_handle.include?(raw)
      end

    end

    # These are the raws we care about.
    def raws_to_handle
      ["422", "376"]
    end
    
    def handle_422(message)
      @ready = true
    end

    alias_method :handle_376, :handle_422

    # Output something to the console and to the socket.
    def response(message)
      @connection.puts(message)
    end

    def me
      @nick
    end

  end

end
