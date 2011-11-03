#
# Cookbook Name:: dd-agent
# Recipe:: default
#
# Copyright 2011, Datadog, Inc.
#
# All rights reserved - Do Not Redistribute
#

# Only support Debian & Ubuntu (RedHat et al. coming soon)
case node.platform
when "debian", "ubuntu"
  apt_repository 'datadog' do
    keyserver 'keyserver.ubuntu.com'
    key 'C7A7DA52'
    uri node.datadog.repo
    distribution "unstable"
    components ["main"]
    action :add
  end

  package 'datadog-agent'

  service "datadog-agent" do
    action :enable
    supports :restart => true
  end

  directory "/etc/dd-agent" do
      owner "root"
      group "root"
      mode 0755
  end

  if node.attribute?("datadog") and node.datadog.attribute?("api_key")
      template "/etc/dd-agent/datadog.conf" do
          owner "root"
          group "root"
          mode 0644
          variables(:api_key => node[:datadog][:api_key], :dd_url => node[:datadog][:url])
          notifies :restart, "service[datadog-agent]", :immediately
      end
  else
      raise "dd-agent: please edit attributes/default.rb and set you API key"
  end
end
