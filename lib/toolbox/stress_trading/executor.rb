module Toolbox
  module StressTrading
    class Executor
      include ::Toolbox::Helpers

      attr_accessor :config

      def initialize(config)
        @config = config
      end

      def prepare_traders
        traders = config.value(:traders).split(',')
        Kernel.puts ''
        traders.each(&method(:register_user))
        Kernel.print 'Making each trader billionaire... '
        traders.each(&method(:become_billionaire))
        Kernel.puts 'OK'
      end

      def traders

      end
      memoize :traders

      def call
        binding.pry
        @statistics_mutex      = Mutex.new
        @created_orders_number = 0
        @times_min, @times_max, @times_count, @times_total = nil, nil, 0, 0.0

        prepare_traders

        install_handlers_for_process_signals
        @launched_at = Time.now
        create_and_run_workers
        @completed_at = Time.now
      end
    end
  end
end
