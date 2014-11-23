#
# Cookbook Name:: middleware
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

########
# apache
########
package "httpd" do
  action :install
end

template "set apache conf" do
  path "/etc/my.conf"
  source "my.conf"
  mode 0600
end

template "set apache conf includer" do
  path "/etc/httpd/conf.d/virtualhost.conf"
  source "virtualhost.conf"
  mode 0600
  notifies :reload, 'service[httpd]'
end

execute "mkdir /etc/httpd/conf.d/sites" do
  command "mkdir -p /etc/httpd/conf.d/sites"
  action :run
end

template "set wordpress apache conf" do
  path "/etc/httpd/conf.d/sites/#{node["middleware"]["wordpress"]["project_name"]}.conf"
  source "project_name.conf.erb"
  mode 0600
  variables({
    :install_path => node["middleware"]["wordpress"]["install_path"],
    :project_name => node["middleware"]["wordpress"]["project_name"],
  })
end

service "httpd" do
  action [ :enable, :start ]
  supports :reload => true
end


########
# mysql
########
%w{mysql mysql-server mysql-devel}.each do |pkg_name|
  package pkg_name do
    action :install
  end
end

service "mysqld" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end


########
# php
########
%w{php php-devel php-mbstring php-mysql php-pdo php-xml php-gd}.each do |pkg_name|
  package pkg_name do
    action :install
  end
end

##########
# sshpass for WordMove
##########
package "sshpass" do
  action :install
end

#################
# charset encode
#################
execute "localdef" do
  user "root"
  command "localedef -f UTF-8 -i ja_JP ja_JP.UTF-8"
  action :run
end


