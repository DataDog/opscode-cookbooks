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
    # Get the key
    execute "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7A7DA52" do
      not_if "apt-key list | grep C7A7DA52"
    end

    # Add the repo
    template "/etc/apt/sources.list.d/datadog.list" do
        owner "root"
        group "root"
        mode 0755
        variables(
            :repo => node.datadog.repo
        )
    end

    # Update the repo
    execute "apt-get update"

    package "datadog-agent" do
        action [ :install, :upgrade ]
    end

    service "datadog-agent" do
        action :nothing
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
