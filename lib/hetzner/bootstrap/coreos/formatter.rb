module Hetzner
  class Bootstrap
    class CoreOS
      class Formatter
        attr_accessor :color
        attr_accessor :text

        def initialize(options = {})
          @text = options[:text]
          @color_code = options[:color_code]
          "\e[#{color_code}m#{text}\e[0m"
        end

        def colorize(text, color_code)
          Hetzner::Bootstrap::CoreOS::Formatter.new(text: text, color_code: color_code)
        end

        def self.red(text)
          Hetzner::Bootstrap::CoreOS::Formatter.new(text: text, color_code: 31)
        end
        
        def green(text)
          Hetzner::Bootstrap::CoreOS::Formatter.new(text: text, color_code: 32)
        end
        
        def yellow(text)
          Hetzner::Bootstrap::CoreOS::Formatter.new(text: text, color_code: 33)
        end
      end
    end
  end
end
