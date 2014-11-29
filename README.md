# hetzner-bootstrap-coreos

This gem allows to bootstrap CoreOS on a Hetzner root server.

[![Gem Version](https://badge.fury.io/rb/hetzner-bootstrap-coreos.png)](http://badge.fury.io/rb/hetzner-bootstrap-coreos)

## What it does:

In our case we are running a large [CoreOS](https://coreos.com) cluster and which uses bare metal servers hosted at Hetzner. This Ruby gem helps to fully automate the provisioning of CoreOS on a Hetzner root server.

Warning: All existing data on the system will be lost!

## Requirements:

First of all retrieve your API login credentials from the Hetzner admin interface at [https://robot.your-server.de](https://robot.your-server.de). Additionally you need the IP address of the shipped system.

## Implemented steps:

1. Enable Rescue Mode (using Hetzner's webservice)
2. Resetting the System to boot into rescue mode (using Hetzner's webservice)
3. Log into the rescue system, write your cloud config file and launch the installation
4. Reboot
5. Verify installation (very basic check but can be overwritten)
6. Copy your local ssh public-key into root's .authorized_keys
7. Adds the generated server key into your `$HOME/.ssh/known_hosts` file
8. Execute `post_install` hooks (optional)

## Example:

See `example.rb` file for usage.

Warning: All existing data on the target system will be lost!

```ruby

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

```

Installation:
-------------

**gem install hetzner-bootstrap-coreos**

Warnings:
---------

* All existing data on the system will be wiped on bootstrap!
* This is not an official Hetzner AG project.
* The gem and the author are not related to Hetzner AG!

**Use at your very own risk. Satisfaction is NOT guaranteed.**

## Thank you greeting

This Ruby gem is inspired by the [hetzner-bootstrap](https://github.com/rmoriz/hetzner-bootstrap) gem and requires the underlying wrapper for the Hetzner server management API [hetzner-api](https://github.com/rmoriz/hetzner-api). Thus I want to thank [Roland Moriz](https://roland.io/developer) a lot for his great work! 

Copyright
---------

Copyright © 2014 Christoph Pilka ([Asconix Systems AS](https://www.asconix.com))