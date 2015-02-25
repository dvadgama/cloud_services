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
    
    def get_id(name)
      machine.servers.map { | server | server.id if server.name == name and server.state  != 'TERMINATED' }.compact.first
    end
    
    def status(name)
      machine.servers.map { | server | server.state if server.name == name and server.state  != 'TERMINATED' }.compact.first
    end
    
    def create                       
      puts "creating Google Compute instance #{resource[:name]}"
      
      disk = machine.disks.create({:name => resource[:name],:size_gb => resource[:disk_size],:zone_name => resource[:region],:source_image => resource[:template] })
      disk.wait_for { disk.ready?  }

      server = machine.servers.create({ :machine_type => resource[:template_type],:name => resource[:name],:zone_name => resource[:region],:disks => [disk.get_as_boot_disk(true)], })     
      server.wait_for { ready? }
    end
    
    def destroy
      
      puts "destroying Google Compute instance #{resource[:name]}"
      server = machine.servers.get(name)
     
      server.destroy
      server.wait_for { state == 'TERMINATED' }
      
      machine.disks.get(name).destroy
     
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