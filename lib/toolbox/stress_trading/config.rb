module Toolbox
  module StressTrading
    class Config
      KNOWN_CONFIG_OPTIONS = %w[
        root_url
        currencies
        markets
        traders
        orders
        threads
        min_volume
        max_volume
        volume_step
        min_price
        max_price
        price_step
        api_v2_jwt_key
        api_v2_jwt_algorithm
        management_api_v1_jwt_key
        management_api_v1_jwt_signer
        management_api_v1_jwt_algorithm
        report_yaml
      ].freeze

      def self.with_file(file_path=nil, config={})
        overlays = [
          ConfigFile.new(file_path, config),
          ConfigDefaults.new,
          ConfigNull.new
        ]
        new(overlays)
      end

      def initialize(overlays)
        @overlays = Array(overlays)
      end

      def overlay_for_key(key)
        @overlays.detect{ |overlay| overlay.has_key?(key) }
      end

      def value(key)
        o = overlay_for_key(key)
        if o
          o.value(key)
        else
          # No overlay said it could handle this key, bail out with nil.
          nil
        end
      end

      class ConfigNull
        def value(*)
          nil
        end

        def has_key?(*)
          true
        end
      end

      class ConfigDefaults
        DEFAULTS = {
          traders:                          2,
          orders:                           1000,
          threads:                          5,
          min_volume:                       1,
          max_volume:                       100,
          volume_step:                      10,
          min_price:                        0.5,
          max_price:                        1.5,
          price_step:                       0.1,
          api_v2_jwt_algorithm:             'RS256',
          management_api_v1_jwt_signer:     'applogic',
          management_api_v1_jwt_algorithm:  'RS256',
          report_yaml:                      'stress_trading_results.yml'
        }.freeze

        def value(key)
          DEFAULTS[key]
        end

        def has_key?(key)
          DEFAULTS.has_key?(key)
        end
      end

      class ConfigFile
        def initialize(file_path=nil, config={})
          @config = config || {}
          @resolved_file_path = file_path || determine_file_path
          load_file
        end

        def value(key)
          if @file_loaded
            val = @settings[key]
            val.to_s.strip.length.zero? ? nil : val
          else
            nil
          end
        end

        def has_key?(key)
          @settings.has_key?(key)
        end

        private

        attr_reader :context

        def load_file
          @settings = {}
          if !File.exist?(@resolved_file_path)
            @file_loaded = false
            return
          end

          begin
            raw_file = File.read(@resolved_file_path)
            erb_file = ERB.new(raw_file).result(binding)
            parsed_yaml = YAML.load(erb_file)
            file_settings = parsed_yaml

            if file_settings.is_a? Hash
              @settings = file_settings
              @file_loaded = true
            else
              @file_loaded = false
            end
          rescue Exception => e # Explicit `Exception` handling to catch SyntaxError and anything else that ERB or YAML may throw
            @file_loaded = false
          end
        end

        def determine_file_path
          File.join("config", "stress_trading.yml")
        end
      end
    end
  end
end
