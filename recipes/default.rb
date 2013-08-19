# services
service "sysklogd" do
  action :stop
  ignore_failure true
end

# install syslog-ng
execute "enable syslog-ng" do
  command "echo '=app-admin/syslog-ng-#{node[:papertrail][:version]} ~amd64' >> /etc/portage/package.keywords/local"
  not_if "grep '=app-admin/syslog-ng-#{node[:papertrail][:version]} ~amd64' /etc/portage/package.keywords/local"
end


package 'app-admin/syslog-ng' do
  version node[:papertrail][:version]
  action :install
end

service "syslog-ng" do
  supports :restart => true
  action [:enable, :start]
end

# certificate
remote_file '/etc/syslog.papertrail.crt' do
  source 'https://papertrailapp.com/tools/syslog.papertrail.crt'
  checksum '7d6bdd1c00343f6fe3b21db8ccc81e8cd1182c5039438485acac4d98f314fe10'
  mode '0644'
end

directory '/etc/syslog-ng/cert.d' do
  recursive true
end

link '/etc/syslog-ng/cert.d/2f2c2f7c.0' do
  to '/etc/syslog.papertrail.crt'
end

# config
template '/etc/syslog-ng/syslog-ng.conf' do
  source 'syslog-ng.conf.erb'
  mode '0644'
  variables(node[:papertrail])
  notifies :restart, resources(:service => 'syslog-ng'), :delayed
end

# install gem
execute 'install remote_syslog gem' do
  command "gem install remote_syslog -v '#{node[:papertrail][:gem_version]}'"
  creates '/usr/bin/remote_syslog'
end

# remote_syslog config file
template '/etc/log_files.yml' do
  source 'log_files.yml.erb'
  mode '0644'
  variables(node[:papertrail])
end

# init.d config file
template '/etc/conf.d/remote_syslog' do
  source 'remote_syslog.confd.erb'
  mode '0644'
end

# init.d script
template '/etc/init.d/remote_syslog' do
  source 'remote_syslog.initd.erb'
  mode '0755'
end

# restart
execute "/etc/init.d/remote_syslog restart"