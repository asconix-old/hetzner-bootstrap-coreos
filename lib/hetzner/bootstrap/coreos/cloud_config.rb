module Hetzner
  class Bootstrap
    class CoreOS
      class CloudConfig
        attr_accessor :raw_cloud_config

        def initialize(param)
          if param.is_a? Hetzner::Bootstrap::CoreOS::CloudConfig
            return param
          elsif param.is_a? String
            @raw_cloud_config = param
          end
        end

        def to_s
          @raw_cloud_config
        end
      end
    end
  end
end
