class cloud_services::machine (
  $provider = '',
  $access_key_id = '',
  $access_key = '',
  $region = '',
  $template = '',
  $template_type = '',
  $project_id = '',
  $client_email = '',
  $key_location = '',
  $disk_size = ''){
  
  cloud_machine { $host_name:
                  :provider      => $provider,
                  :access_key_id => $access_key,
		  :access_key    => $access_key,
		  :region        => $region,
		  :template      => $template,
		  :template_type => $template_type,
		  :project_id    => $project_id,
		  :client_email  => $client_email,
		  :key_location  => $key_location,
		  :disk_size     => $disk_size,
                 }
}