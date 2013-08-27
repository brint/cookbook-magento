define :fpm_allow do

  php_conf =  if platform?('centos', 'redhat')
                ["/etc", "/etc/php.d"]
              else
                ["/etc/php5/fpm", "/etc/php5/conf.d"]
              end
  
  if node['php-fpm']['slaves'].empty?
  	permit = ""
  else
    permit = ",#{node['php-fpm']['slaves'].join(",")}"
  end

  node['php-fpm']['pools'].each do |pool|
    bash "Permit slave nodes of #{pool} to leverage this PHP-FPM setup" do
      cwd "#{php_conf[0]}/pools/" # php.ini location
      code <<-EOH
      sed -i 's/listen.allowed_clients = .*/listen.allowed_clients = 127.0.0.1#{permit}/' #{pool}.conf
      EOH
      notifies :restart, resources(:service => "php-fpm")
    end
  end
end
