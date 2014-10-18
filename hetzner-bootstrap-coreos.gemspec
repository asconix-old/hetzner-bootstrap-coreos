# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hetzner/bootstrap/coreos/version"

Gem::Specification.new do |s|
  s.name        = "hetzner-bootstrap-coreos"
  s.version     = Hetzner::Bootstrap::CoreOS::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christoph Pilka"]
  s.email       = ["c.pilka@asconix.com"]
  s.homepage    = "http://www.asconix.com"
  s.summary     = %q{Bootstrapping of the root servers at Hetzner with CoreOS}
  s.description = %q{Bootstrapping of the root servers at Hetzner with CoreOS}

  s.add_dependency 'hetzner-api', '>= 1.1.0'
  s.add_dependency 'net-ssh',     '>= 2.6.0'
  s.add_dependency 'erubis',      '>= 2.7.0'

  s.add_development_dependency "rspec",   ">= 2.13.0"
  s.add_development_dependency "rake"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
