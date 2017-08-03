#!/usr/bin/env ruby
require "rubygems"
require "hetzner-bootstrap-coreos"

# Retrieve your API login credentials from the Hetzner admin interface
# at https://robot.your-server.de and assign the appropriate environment
# variables:
#
#     $~ export HBC_ROBOT_USER="hetzner_user"
#     $~ export HBC_ROBOT_PASSWORD="verysecret"
#     $~ export HBC_IP_ADDRESS="1.2.3.4"
#     $~ export HBC_HOSTNAME="core-01.example.com"
#     $~ export HBC_PUBLIC_KEYS="ssh-rsa AAAA...Ws3Fr info@example.com"
#
# Next launch the bootstrap script:
#
#     $~ ./example.rb

bs = Hetzner::Bootstrap::CoreOS.new(
	:api => Hetzner::API.new(ENV['HBC_ROBOT_USER'], ENV['HBC_ROBOT_PASSWORD'])
)

# Main configuration (cloud-config) 
cloud_config = <<EOT
hostname: <%= hostname %>
ssh_authorized_keys:
  - <%= public_keys %>
EOT

# The post_install hook is the right place to launch further tasks (e.g.
# software installation, system provisioning etc.)
post_install = <<EOT
  # TODO
EOT

bs << { :ip => ENV['HBC_IP_ADDRESS'],
    :cloud_config => cloud_config,
    :hostname => ENV['HBC_HOSTNAME'],
    :public_keys => ENV['HBC_PUBLIC_KEYS'],
    :post_install => post_install
}

bs.bootstrap!
