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

bs << { :ip => "213.133.109.169",
    :cloud_config => cloud_config,
    :hostname => 'artemis.massive-insights.com',
    :public_keys => 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxpbPqgja8qK0pRBu423nuj7ZqJY/VPyABvBtcHQBpnaz20hSo89K+yEJmdg4upKk54906u7OT5tGaFpTYQKUxGgdKO1my8y2tXHDdTGw1A3BZotgIwDDvNTrIYW8JlGOBTVQuHGm6EYf8tEVut+dhueSe0VsK3keTQQwwatSf4uBgYxRMorsVWFVwk+YH2RKC25pbh0teoagL1TVts4OqGTcRJtrO9PHkuHFNCqA5IQVf+BRzwyCNWGaLuX3W/+DOOx3u76UhKBWrWXicVksFUD7tnFJrZohLu6PtKBoSSlVYVO/YgXQEJtsvG1EmEaoMnM2TvdzIWcopdd2jIo8Cw== c.pilka@asconix.com',
    :post_install => post_install
}

bs.bootstrap!
