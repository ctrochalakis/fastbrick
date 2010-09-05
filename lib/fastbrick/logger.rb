require 'logger'

module Fastbrick
  module Logging
    attr_accessor :whoami

    def logger
      @logger ||= Logger.new(STDOUT).tap { |log|
        log.level = ENV['DEBUG'] ? Logger::DEBUG : Logger::WARN      
      }
     end

    def debug(msg)
      logger.debug "[#{whoami}]: #{msg}"
    end

    def info(msg)
      logger.info "[#{whoami}]: #{msg}"
    end

  end
end
