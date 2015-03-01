require_relative '../cloud_machine'
#Fog.mock!
#Fog::Mock.reset

Puppet::Type.type(:cloud_machine).provide(:google) do
  desc <<-EOT
    This provider is to support Google Compute Provider for type cloud_machine
    EOT
    
     
    confine :osfamily => [:RedHat,:Debian]
    
    #ToDo: implement the alternative way to aquire project_id,client_email & key_location
    # e.g. from bash ? from .fog file
    
    
    mk_resource_methods
    
    def machine
      @machine ||= Fog::Compute.new({:provider => @resource[:provider], 
                                     :google_project => @resource[:project_id],
                                     :google_client_email => @resource[:client_email],
                                     :google_key_location => @resource[:key_location],})
  
    end
    
    def status(name)
      machine.servers.map { | server | server.state if server.name == name and server.state  != 'TERMINATED' }.compact.first
    end
    
    def create     
      
      disk = machine.disks.create({:name => resource[:name],
                                   :size_gb => resource[:disk_size],
                                   :zone_name => resource[:region],
                                   :source_image => resource[:template],})
       
       disk.wait_for { disk.ready?  }
      
      case resource[:bootstrap]
      when :false
       puts "creating Google Compute instance #{resource[:name]}"
       
       server = machine.servers.create({:name => resource[:name],
                                        :machine_type => resource[:template_type],
                                        :zone_name => resource[:region],
                                        :disks => [disk.get_as_boot_disk(true)],})
       
       server.wait_for { ready? }
       
      when :true
	puts "Bootstrapping Google Compute instance #{resource[:name]}"
	
	server = machine.servers.bootstrap({:name => resource[:name], 
	                                    :machine_type => resource[:template_type],
	                                    :zone_name => resource[:region],
	                                    :disks => [disk.get_as_boot_disk(true)], 
	                                    :private_key_path => resource[:ssh_private_key],
	                                    :public_key_path => resource[:ssh_public_key],
	                                    :username => resource[:bootstrap_user],})
       
	server.wait_for { server.ready? }
	
	file = File.basename(resource[:bootstrap_file])
	src_dir = File.expand_path(File.dirname(resource[:bootstrap_file]))
	dst_dir = '/tmp'
	
	src = src_dir + '/' + file
	dst = dst_dir + '/' + file
	
	server.scp(src,dst_dir)
	server.ssh("chmod +x #{dst}")
	server.ssh("sudo #{dst}")
      end
      
    end
    
    def terminate
      
      puts "Destroying Google Compute instance #{resource[:name]}"
      
      server = machine.servers.get(resource[:name])
     
      server.destroy
      server.wait_for { state == 'TERMINATED' }
      
      machine.disks.get(resource[:name]).destroy
     
    end
    
    def running 
      #FixME: creating new, since start operation is not supported in FOG
      self.create if status(resource[:name]) ==  nil 
    end
    
    def stopped
      #FIXME: destroying, since stop operation is not supported in FOG        
      self.destroy
    end
    
    def exists?
	return true unless status(resource[:name]) == nil
    end 
    
end