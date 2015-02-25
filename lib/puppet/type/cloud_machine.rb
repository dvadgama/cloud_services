module Puppet
  Type.newtype(:cloud_machine)  do
    @doc = "Mange creation and deletion of the virtual machine in aws cloud using fog
            ToDo: 
	      1) make it work with other cloud type too (which should be relatively easy thanks to fog!)
	      2) enhence the feature set
	      
	      e.g. usage
	        cloud_machine { 'myvm':
		                    provider =>  'aws',
		                    template => 'ami_1900',
				    region   => 'eu-us',
				    access_key_id => 'aws_key_id';
				    access_key     => 'aws_secret_key',
				 }"
	      
    ensurable do
      desc <<-EOT
        We need to use customised ensureable for reason , machine can be in following state 
         present -> i.e. created ( may be running  or stopped )
         absent -> i.e. machine should not be present and destoyed if it present
         running -> should be present and running
         stopped -> should be present and stopped
         This logic is implemtned in insync?(is) 
      EOT
      
      newvalue(:present)  do
	provider.create
      end
      
      newvalue(:absent) do
	provider.destroy
      end
      
      newvalue(:running) do
	provider.running
      end
      
      newvalue(:stopped) do
	provider.stopped
      end
      
      defaultto :present
      
      
      def insync?(is)
	
	is_value = is.to_sym
	should_value = @should.first.to_sym
	
	case should_value
	when :present 
	  return true if is_value == :present or  is_value == :running or is_value ==  :stopped
	when :running, :stopped, :absent
	  return  true if is_value  ==  should_value
	else
	  return false
	end
	
      end
      
      
    end
  
    
    desc 'Here we enforce the mandtory properties/parameters'
    
    validate  do
      fail("provider name is required to build a cloud_machine") if self[:provider] ==  nil
      
	case self[:provider]
	when :aws
	 self[:template] = 'ami-f0b11187'                         if self[:template] == nil  
	 self[:template_type] = 't2.micro'                        if self[:template_type] == nil
         self[:region] = 'eu-west-1'                              if self[:region] == nil
	 fail("access_key_id is required for #{self[:provider]}") if self[:access_key] == nil
	 fail("access_key is required for #{self[:provider]}")    if self[:access_key_id] == nil
	 
	when :google
	  self[:template] = 'ubuntu-1410-utopic-v20150202'            if self[:template] == nil
	  self[:template_type] = 'f1-micro'                           if self[:template_type] == nil
	  self[:region] = 'europe-west1-b'                            if self[:region] == nil  
	  self[:disk_size] = 10                                       if self[:disk_size] == nil
	  fail("project_id is required for #{self[:provider]}")       if self[:project_id] == nil
	  fail("client_email is required for #{self[:provider]}")     if self[:client_email] == nil
	  fail("key_location is required for #{self[:key_location]}") if self[:key_location] == nil
	end
	
    end
    
    
    newparam(:name, :namevaar => true ) do
      desc <<-EOT 
        name of the virtual machine, which i might change in future to be FQDN
        so that it can be used as both 
        1) host name entry
        2) short hostname as a vm name (which must be uniq in zone atleast
      EOT
      
      validate do | value | 
        fail(" \"#{value}\" does not match the expected name pattern") if value =~ /\W+/
      end
    
      def insync?(is)
        is.downcase == should.downcase
      end
	
    end
    
    #using this from the packae.rb type, for now I'm sure how it works but,it allows me to have provider as  parameter 
    providify
    paramclass(:provider).isnamevar
    
    def self.title_patterns
      # This is the default title pattern for all types, except hard-wired to
      # set only name.
      [ [ /(.*)/m, [ [:name] ] ] ]
    end
    
    newparam(:template) do
      desc <<-EOT
        This is the name of temlate machine, which would be
         - image_id in aws  from which you wish to clone your new machine
         -  a template machine name in case of ESX/VMWare  
         - so on
         EOT
      
      validate do | value |
        fail("template name \"#{value}\" does not match the expected name pattern") unless value =~ /\w+/
      end
      
      isrequired
    end
   
    newparam(:template_type) do
      desc <<-EOT
       This is the machine_type/flavour_id , basically a insatance type'
      EOT
      
      isrequired
    end
    
    
    newparam(:region) do
      desc <<-EOT
       Specify region , where you want to build the machine,
       i am not going to default to any region, since, i would like to support more than aws in future
      EOT
      
      validate do |value|
	fail("region name \"#{value}\" does not match the expected name pattern") unless value =~ /\w+/
      end
      isrequired
    end
    
    newparam(:access_key_id) do
      desc <<-EOT 
        access key id to  api,  e.g. aws_access_key_id.
        This is not a mandtory field since, if you are running this code through machine with approprite role (least in aws)
        Then, you do not need to supply any key id or key
      EOT
      
      validate do | value |
	fail("access_key_id => \"#{value}\" must not contain space") if value =~ / /
      end
      
    end
    
    
   newparam(:access_key) do
      desc 'access key to  api,  e.g. aws_secret_access_key, this is nor mandtory for same reason aaas access_key_id'
      
      validate do | value |
	fail("access_key => \"#{value}\" must not contain space") if value =~ / /
      end
      
   end
   
    
    #Properties for google api
    newparam(:project_id) do
      desc 'Project ID for google compute'
    end
    
    
    newparam(:client_email) do
      desc 'this translates to google_client_email'
    end
    
    newparam(:key_location) do
      desc 'This translates to google_key_location'
    end
    
    newparam(:disk_size) do
      desc 'This param translates as :size_gb for google disk'
      
       munge do | value |
	value.to_i unless value.class.to_s == 'Fixnum'
      end
      
      validate do | value |
	fail("value must contain only numbers") unless value.class.to_s == 'Fixnum'
      end
      
    end
    
  end 
end 