log_level                :info
log_location             STDOUT
node_name                'chef-webui'
client_key               '/etc/chef-server/chef-webui.pem'
validation_client_name   'chef-validator'
validation_key           '/etc/chef-server/chef-validator.pem'
chef_server_url          'http://localhost'
syntax_check_cache_path  '/root/.chef/syntax_check_cache'