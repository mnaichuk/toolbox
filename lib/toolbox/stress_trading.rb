require_relative 'stress_trading/config'
require_relative 'stress_trading/executor'

module Toolbox
  module StressTrading
    class << self
      def run!
        executor.call
      end

      def executor
        binding.pry
        @executor ||= Executor.new(config)
      end

      def config
        @config ||= Config.with_file
      end


    end
  end
end
