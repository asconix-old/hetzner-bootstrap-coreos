require 'hetzner-api'
require 'spec_helper'

describe "Bootstrap" do
  before(:all) do
    @api = Hetzner::API.new API_USERNAME, API_PASSWORD
    @bootstrap = Hetzner::Bootstrap::CoreOS.new :api => @api
  end

  context "add target" do
    
    it "should be able to add a server to operate on" do
      @bootstrap.add_target proper_target
      @bootstrap.targets.should have(1).target
      @bootstrap.targets.first.should be_instance_of Hetzner::Bootstrap::CoreOS::Target
    end

    it "should have the default cloud config file if none is specified" do
      @bootstrap.add_target proper_target
      @bootstrap.targets.first.cloud_config.should be_instance_of Hetzner::Bootstrap::CoreOS::CloudConfig
    end

    it "should raise an NoCloudConfigProvidedError when no cloud config option provided" do
      lambda {
      @bootstrap.add_target improper_target_without_cloud_condfig
      }.should raise_error(Hetzner::Bootstrap::CoreOS::Target::NoCloudConfigProvidedError)
    end
  
  end

  def proper_target
    return {
      :ip            => "1.2.3.4",
      :login         => "root",
      :password      => "verysecret",
      :rescue_os     => "linux",
      :rescue_os_bit => "64",
      :cloud_config  => default_cloud_config
    }
  end

  def improper_target_without_cloud_config
    proper_target.select { |k,v| k != :cloud_config }
  end

  def default_cloud_config
    "foobar"
  end
end
