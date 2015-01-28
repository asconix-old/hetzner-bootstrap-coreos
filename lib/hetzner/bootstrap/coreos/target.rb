require 'erubis'
require 'net/ssh'
require 'socket'
require 'timeout'
require 'colorize'

module Hetzner
  class Bootstrap
    class CoreOS
      class Target
        attr_accessor :ip
        attr_accessor :login
        attr_accessor :password
        attr_accessor :cloud_config
        attr_accessor :rescue_os
        attr_accessor :rescue_os_bit
        attr_accessor :actions
        attr_accessor :hostname
        attr_accessor :post_install
        attr_accessor :post_install_remote
        attr_accessor :public_keys
        attr_accessor :bootstrap_cmd
        attr_accessor :logger

        def initialize(options = {})
          @rescue_os     = 'linux'
          @rescue_os_bit = '64'
          @retries       = 0
          @bootstrap_cmd = 'export TERM=xterm; /tmp/coreos-install -d /dev/sda -C stable -c /tmp/cloud-config.yaml'
          @login         = 'root'

          if cc = options.delete(:cloud_config)
            @cloud_config = CloudConfig.new cc
          else
            raise NoCloudConfigProvidedError.new 'No cloud config file provided.'
          end

          options.each_pair do |k,v|
            self.send("#{k}=", v)
          end
        end

        def enable_rescue_mode(options = {})
          result = @api.enable_rescue! @ip, @rescue_os, @rescue_os_bit
          if result.success? && result['rescue']
            @password = result['rescue']['password']
            reset_retries
            logger.info "IP: #{ip} | username: #{@login} | password: #{@password}".colorize(:magenta)
          elsif @retries > 3
            logger.error "Rescue system could not be activated".colorize(:red)
            raise CantActivateRescueSystemError, result
          else
            @retries += 1

            logger.warn "Problem while trying to activate rescue system (retries: #{@retries})".colorize(:yellow)
            @api.disable_rescue! @ip

            rolling_sleep
            enable_rescue_mode options
          end
        end

        def reset(options = {})
          result = @api.reset! @ip, :hw

          if result.success?
            reset_retries
          elsif @retries > 3
            logger.error "Resetting through web service failed.".colorize(:red)
            raise CantResetSystemError, result
          else
            @retries += 1
            logger.warn "Problem while trying to reset/reboot system (retries: #{@retries})".colorize(:yellow)
            rolling_sleep
            reset options
          end
        end

        def port_open? ip, port
          ssh_port_probe = TCPSocket.new ip, port
          IO.select([ssh_port_probe], nil, nil, 2)
          ssh_port_probe.close
          true
        end

        def wait_for_ssh_down(options = {})
          loop do
            sleep 2
            Timeout::timeout(4) do
              if port_open? @ip, 22
                logger.debug "SSH UP".colorize(:magenta)
              else
                raise Errno::ECONNREFUSED
              end
            end
          end
        rescue Timeout::Error, Errno::ECONNREFUSED
          logger.debug "SSH down".colorize(:magenta)
        end

        def wait_for_ssh_up(options = {})
          loop do
            Timeout::timeout(4) do
              if port_open? @ip, 22
                logger.debug "SSH up".colorize(:magenta)
                return true
              else
                raise Errno::ECONNREFUSED
              end
            end
          end
        rescue Errno::ECONNREFUSED, Timeout::Error
          logger.debug "SSH down".colorize(:magenta)
          sleep 2
          retry
        end

        def installimage(options = {})
          cloud_config = render_cloud_config

          remote do |ssh|
            ssh.open_channel do |channel|
              channel.exec("cat > /tmp/cloud-config.yaml") do |ch, success|
                channel.on_data do |ch,data|
                  res << data
                end
                channel.send_data(cloud_config)
                channel.eof!
              end
            end
            ssh.exec! "wget https://raw.githubusercontent.com/coreos/init/master/bin/coreos-install -P /tmp"
            ssh.exec! "chmod a+x /tmp/coreos-install"
            logger.info "Remote executing: #{@bootstrap_cmd}".colorize(:magenta)
            output = ssh.exec!(@bootstrap_cmd)
            logger.info output
          end
        end

        def reboot(options = {})
          logger.info "Rebooting ...".colorize(:magenta)
          remote do |ssh|
            ssh.exec!("reboot")
          end
        end

        def verify_installation(options = {})
          logger.info "Verifying the installation ...".colorize(:magenta)
          @login = 'core'
          remote(password: nil) do |ssh|
            working_hostname = ssh.exec!("cat /etc/hostname")
            if @hostname == working_hostname.chomp
              logger.info "The installation has been successful".colorize(:green)
            else
              raise InstallationError, "Hostnames do not match: assumed #{@hostname} but received #{working_hostname}"
            end
          end
        end

        def remove_from_local_known_hosts(options = {})
          `ssh-keygen -R #{@hostname}`
          `ssh-keygen -R #{@ip}`
        end

        def update_local_known_hosts(options = {})
          remote do |ssh|
            logger.info "Removing SSH keys for #{@hostname} from local ~/.ssh/known_hosts file ...".colorize(:magenta)
            `ssh-keygen -R #{@hostname}`
            `ssh-keygen -R #{@ip}`
          end
        rescue Net::SSH::HostKeyMismatch => e
          e.remember_host!
          logger.info "Remote host key has been added to local ~/.ssh/known_hosts file.".colorize(:green)
        end

        def post_install(options = {})
          return unless @post_install

          post_install = render_post_install
          logger.info "Executing post_install:\n #{post_install}".colorize(:magenta)

          output = local do
            `#{post_install}`
          end

          logger.info output
        end

        def post_install_remote(options = {})
          return unless @post_install_remote

          remote do |ssh|
            @post_install_remote.split("\n").each do |cmd|
              cmd.chomp!
              logger.info "executing #{cmd}".colorize(:magenta)
              ssh.exec!(cmd)
            end
          end
        end

        def render_cloud_config
          eruby = Erubis::Eruby.new @cloud_config.to_s

          params = {}
          params[:hostname] = @hostname
          params[:ip] = @ip
          params[:public_keys] = @public_keys

          return eruby.result(params)
        end

        def render_post_install
          eruby = Erubis::Eruby.new @post_install.to_s

          params = {}
          params[:hostname] = @hostname
          params[:ip]       = @ip
          params[:login]    = @login
          params[:password] = @password

          return eruby.result(params)
        end

        def use_api(api_obj)
          @api = api_obj
        end

        def use_logger(logger_obj)
          @logger = logger_obj
          @logger.formatter = default_log_formatter
        end

        def remote(options = {}, &block)
          default = { :password => @password }
          default.merge! options
          Net::SSH.start(@ip, @login, default) do |ssh|
            block.call ssh
          end
        end

        def local(&block)
          block.call
        end

        def reset_retries
          @retries = 0
        end

        def rolling_sleep
          sleep @retries * @retries * 3 + 1 # => 1, 4, 13, 28, 49, 76, 109, 148, 193, 244, 301, 364 ... seconds
        end

        def default_log_formatter
           proc do |severity, datetime, progname, msg|
             caller[4]=~/`(.*?)'/
             "[#{datetime.strftime "%H:%M:%S"}][#{sprintf "%-15s", ip}][#{$1}] #{msg}\n"
           end
        end

        class NoCloudConfigProvidedError < ArgumentError; end
        class CantActivateRescueSystemError < StandardError; end
        class CantResetSystemError < StandardError; end
        class InstallationError < StandardError; end
      end
    end
  end
end
