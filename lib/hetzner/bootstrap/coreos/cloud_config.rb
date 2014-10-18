module Hetzner
  class Bootstrap
    class CoreOS
      class CloudConfig
        attr_accessor :raw_config

        def initialize(param)
          if param.is_a? Hetzner::Bootstrap::CoreOS::CloudConfig
            return param
          elsif param.is_a? String
            @raw_template = param
          end
        end

        def to_s
          @raw_template
        end
      end
    end
  end
end
