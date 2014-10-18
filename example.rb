#!/usr/bin/env ruby
require "rubygems"
require "hetzner-bootstrap-coreos"

# Retrieve your API login credentials from the Hetzner admin interface
# at https://robot.your-server.de and assign the appropriate environment
# variables ENV['ROBOT_USER'] and ENV['ROBOT_PASSWORD']

bs = Hetzner::Bootstrap::CoreOS.new(
	:api => Hetzner::API.new(ENV['ROBOT_USER'], ENV['ROBOT_PASSWORD'])
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

bs << { :ip => "1.2.3.4",
	:cloud_config => cloud_config,
	:hostname => 'artemis.massive-insights.com',
    :public_keys => "~/.ssh/id_dsa.pub",
    :post_install => post_install
}

bs.bootstrap!
