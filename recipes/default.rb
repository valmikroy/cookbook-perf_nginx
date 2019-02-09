#
# Cookbook:: perf_nginx
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

node.default['selfsigned_certificate']['destination'] = '/etc/nginx/ssl'

apt_update


package 'nginx' do
  action :install
end

package 'linux-tools-common' do
  action :install
end

package 'linux-tools-generic' do
  action :install
end

package "linux-tools-#{node[:kernel][:release]}" do
  action :install
end

service 'nginx' do
  supports status: true, restart: true, reload: true
  action [ :stop , :disable ]
end



if !(File.exist? node['selfsigned_certificate']['destination'])
	log "No self-signed certificate found (targeted destination: #{node['selfsigned_certificate']['destination']}"
	include_recipe "selfsigned_certificate::default" 
	log "created th server self-signed certificate to #{node['selfsigned_certificate']['destination']}"
else 
	log "Certificate already exists in #{node['selfsigned_certificate']['destination']}, no overriding."
end

template "/etc/nginx/nginx.conf" do   
  source "nginx.conf.erb"
end


directory "/usr/share/nginx/www" do
	recursive true
	action :create
end

cookbook_file "/usr/share/nginx/www/index.html" do
  source "index.html"
  mode "0644"
end
