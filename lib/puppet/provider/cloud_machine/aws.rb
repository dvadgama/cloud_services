require_relative '../cloud_machine'
#Fog.mock!
#Fog::Mock.reset

Puppet::Type.type(:cloud_machine).provide(:aws) do
  desc <<-EOT
    This provider is to support AWS Provider for type cloud_machine
    EOT
    
    confine :osfamily => [:RedHat,:Debian]
    
    #ToDo: implement the alternative way to aquire aws_access_key_id & aws_secret_access_key 
    # e.g. from bash ? from .fog file
    #@connection_resource = [:access_key_id, :access_key, :provider, :region]
    
    
    mk_resource_methods
    
    def machine
      @machine ||= Fog::Compute.new({:provider => @resource[:provider], 
                                            :aws_access_key_id => @resource[:access_key_id],
                                            :aws_secret_access_key => @resource[:access_key],
                                            :region => @resource[:region],})
  
    end
    
    def get_id(name)
      machine.servers.map { | server | server.id if server.tags['Name'] == name and server.state  != 'terminated' }.compact.first
    end
    
    def status(name)
      machine.servers.map { | server | server.state if server.tags['Name'] == name and server.state  != 'terminated' }.compact.first
    end
    
    def create 
      
      case  resource[:bootstrap]
      when :false
        puts "Creating AWS instance #{resource[:name]}"
        server = machine.servers.create({:flavor_id => resource[:template_type],
	                                 :image_id  => resource[:template],
	                                 :tags => {'Name' => resource[:name]}})
	
        server.wait_for { server.ready? }
	
      when :true
	puts "Bootstrapping AWS instance #{resource[:name]}"
		
	server = machine.servers.bootstrap({:flavor_id => resource[:template_type],
	                                    :image_id  => resource[:template],
	                                    :tags => {'Name' => resource[:name]},
	                                    :private_key_path => resource[:ssh_private_key],
	                                    :public_key_path => resource[:ssh_public_key],
	                                    :key_name =>  resource[:keypair], 
	                                    :username => resource[:bootstrap_user]})
	
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
      puts "Destroying AWS instance #{resource[:name]}"
 
      id = get_id(resource[:name])
      server = machine.servers.get(id)
      server.destroy
      server.wait_for { state == 'terminated'}
    end
    
    def running
      
      self.create if status(resource[:name]) == nil
      
      unless status(resource[:name]) == 'running'
	puts "Starting AWS  instance #{resource[:name]}"
	id =  get_id(resource[:name])
	server = machine.servers.get(id)
	server.start
	server.wait_for { state == 'running' }
      end
      
    end
    
    def stopped
      
      unless status(resource[:name]) == 'stopped'
	puts "Stopping AWS instance #{resource[:name]}"
	id =  get_id(resource[:name])
	server = machine.servers.get(id)
	server.stop
	server.wait_for { state == 'stopped' }
      end
     
    end
    
    def exists?
	return true unless status(resource[:name]) == nil
    end 
    
end