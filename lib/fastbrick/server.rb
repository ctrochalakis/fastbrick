require 'webrick'
require 'fastbrick/logger'
module Fastbrick
  module Server
    extend self
    extend Logging
    
    attr_reader :server

    def start(*args, &block)
      @block = block
      self.whoami = :spawner
      debug "bootstraping server.."
      @server = WEBrick::HTTPServer.new(*args)
      debug "spawning actual server"
      @child_pid = spawn

      trap_int
      register_reload

      debug "sleeping..."
      loop { sleep }
    end
   
    def register_reload
      trap(:HUP) {
        debug "Recieved HUP"
        Process.kill(:SIGINT, @child_pid)
        Process.wait(@child_pid)
        @child_pid = spawn
      }
    end

    def trap_int
      trap(:INT) {
        debug "Recieved INT"
        @server.shutdown
        exit!
      }
    end
    
    def spawn(&block)
      fork {
        self.whoami = :actual
        trap_int
        debug "calling block"
        @block.call

        warn "starting server"
        @server.start
      }
    end
  end
end
