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
    :hostname => ENV['HBC_HOSTNAME']
    :public_keys => 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxpbPqgja8qK0pRBu423nuj7ZqJY/VPyABvBtcHQBpnaz20hSo89K+yEJmdg4upKk54906u7OT5tGaFpTYQKUxGgdKO1my8y2tXHDdTGw1A3BZotgIwDDvNTrIYW8JlGOBTVQuHGm6EYf8tEVut+dhueSe0VsK3keTQQwwatSf4uBgYxRMorsVWFVwk+YH2RKC25pbh0teoagL1TVts4OqGTcRJtrO9PHkuHFNCqA5IQVf+BRzwyCNWGaLuX3W/+DOOx3u76UhKBWrWXicVksFUD7tnFJrZohLu6PtKBoSSlVYVO/YgXQEJtsvG1EmEaoMnM2TvdzIWcopdd2jIo8Cw== c.pilka@asconix.com',
    :post_install => post_install
}

bs.bootstrap!
