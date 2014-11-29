require 'benchmark'
require 'logger'

require 'hetzner-api'
require 'hetzner/bootstrap/coreos/version'
require 'hetzner/bootstrap/coreos/target'
require 'hetzner/bootstrap/coreos/cloud_config'

module Hetzner
  class Bootstrap
    class CoreOS
      attr_accessor :targets
      attr_accessor :api
      attr_accessor :actions
      attr_accessor :logger

      def initialize(options = {})
        @targets = []
        # @actions = %w(
            # enable_rescue_mode
            # verify_installation
        # )
        @actions = %w(
            remove_from_local_known_hosts
            enable_rescue_mode
            reset
            wait_for_ssh_down
            wait_for_ssh_up
            update_local_known_hosts
            installimage
            reboot
            wait_for_ssh_down
            wait_for_ssh_up
            update_local_known_hosts
            verify_installation
            post_install
            post_install_remote
        )
        @api = options[:api]
        @logger = options[:logger] || Logger.new(STDOUT)
      end

      def add_target(param)
        if param.is_a? Hetzner::Bootstrap::CoreOS::Target
          @targets << param
        else
          @targets << (Hetzner::Bootstrap::CoreOS::Target.new param)
        end
      end

      def <<(param)
        add_target param
      end

      def bootstrap!(options = {})
        @targets.each do |target|
          target.use_api @api
          target.use_logger @logger
          bootstrap_one_target! target
        end
      end

      def bootstrap_one_target!(target)
        actions = (target.actions || @actions)
        actions.each_with_index do |action, index|
          loghack = "\b" * 24 # remove: "[bootstrap_one_target!] ".length
          target.logger.info "#{loghack}[#{action}] #{sprintf "%-20s", "START"}"
          d = Benchmark.realtime do
            target.send action
          end
          target.logger.info "#{loghack}[#{action}] FINISHED in #{sprintf "%.5f",d} seconds"
        end
      rescue => e
        puts "Something bad happened unexpectedly: #{e.class} => #{e.message}"
      end
    end
  end
end

