require 'directory_watcher'
require 'fastbrick/logger'
require 'fastbrick/server'

module Fastbrick
  extend self
  extend Logging

  attr_reader :server_pid, :block, :watcher

  def fire_server
    @server_pid = fork {
      Server.start(:Port => 5000, &block)
    }
  end

  def register_watcher
    @watcher = DirectoryWatcher.new('.', :glob => '**/*.rb', :interval => 1, :pre_load => true)
    @watcher.add_observer {
      info "File change detected!"
      restart_server
    }
  end

  # We don't have to do anything on SIGINT.
  # The forked child will recieve it too
  # so the `Process.wait` will unblock.
  def register_signals
    trap(:INT) { debug "Recieved INT"; exit!}
  end

  def restart_server
    debug "Sending SIGHUP to spawner"
    Process.kill(:SIGHUP, server_pid)
  end

  def serve(&block)
    self.whoami = :watcher
    @block = block
    fire_server
    register_signals
    register_watcher
    info "Watching for changes.."
    watcher.start
    debug "Waiting for spawner..."
    Process.wait(server_pid)
    info "spawner killed! stopping.."
    watcher.stop
  end

end
