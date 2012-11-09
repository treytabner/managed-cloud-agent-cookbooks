#
# Cookbook Name:: cloudmonitoring
# Recipe:: checks
#
# Copyright 2012, Rackspace
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#check_creator = File.join(Chef::Config[:file_cache_path], "create_check.sh")

#checkfile = cookbook_file check_creator do
#	source "create_check.sh"
#	mode 0755
#	owner "root"
#	group "root"
#	action :nothing
#end
#checkfile.run_action(:create)

#execute "create_load_check" do
#  command "#{check_creator} #{node['cloud_monitoring']['entity']}"
#  user "root"
#end


cloudmonitoring_check  "Root Filesystem Check" do
  target_alias          'default'
  type                  'agent.filesystem'
  details               'target' => '/'
  period                30
  timeout               10
  rackspace_username    node['cloud_monitoring']['rackspace_username']
  rackspace_api_key     node['cloud_monitoring']['rackspace_api_key']
  action :create
end

cloudmonitoring_alarm  "Root File System Alarm" do
  check_label           'Root Filesystem Check'
  metadata            	'template_name' => 'agent.managed_low_filesystem_avail'
  criteria	           "if (metric['avail'] < 102400) {  return new AlarmStatus(CRITICAL, 'Less than 100MB of available space remains'); } return new AlarmStatus(OK, 'More than 100MB of space is available');"
  notification_plan_id  node['cloud_monitoring']['notification_plan']
  action :create
end

cloudmonitoring_check  "Server Load Check" do
  target_alias          'default'
  type                  'agent.load_average'
  period                30
  timeout               10
  rackspace_username    node['cloud_monitoring']['rackspace_username']
  rackspace_api_key     node['cloud_monitoring']['rackspace_api_key']
  action :create
end

cloudmonitoring_check  "Server Swap Check" do
  target_alias          'default'
  type                  'agent.memory'
  period                30
  timeout               10
  rackspace_username    node['cloud_monitoring']['rackspace_username']
  rackspace_api_key     node['cloud_monitoring']['rackspace_api_key']
  action :create
end

