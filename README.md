##<u>cloud_services</u>
This Puppet module provides a custom type for deploying an instance in AWS and/or GCE.  

##<u>Supported Environment Variable</u>
- for AWS instance
 - ENV['aws_access_key_id']
 - ENV['aws_secret_access_key']
- for GCE instance
 - ENV['google_client_email']
 - ENV['google_key_location']

##<u>What it can do?</u>
- it can ** create ** the AWS or GCE instance
- it can ** bootstrap ** the AWS or GCE instnace

##<u>Supported Type</u>
- ###cloud_machine
    - #### Type Properties/Parameters
        - ####Common for both AWS & GCE provider
        <table>
         <tr><u>**provider**</u></tr><tr> currently supports aws and, google provider</tr>  
         <tr><u>**ensure**</u></tr><tr> current ensure-able supports, present,running,stopped and absent with present as a default value</tr>  
         <tr><u>**bootstrap**</u></tr><tr> possible values are true/false and it defaults to false, set it to true if you wish to bootstrap your instance</tr>  
         <tr><u>**bootstrap_file**</u></tr><tr> Required/Useful when bootstrap is set to true, this is location of your bootstrap script</tr>  
         <tr><u>**ssh_public_key**</u><tr> <tr> This is location for the public ssh key , used to connect to a machine during bootstrapping.It defaults to  
          ~/.ssh/aws.pub for AWS  
          ~/.ssh/google.pub  for GCE<tr/>  
        <tr><u>**ssh_private_key**</u><tr> <tr> This is location for the private ssh key , used to connect to a machine during bootstrapping.It defaults to  
          ~/.ssh/aws for AWS  
          ~/.ssh/google  for GCE</tr>  
          <tr><u>**bootstrap_user**</u><tr/><tr>
        </table>  
        - ####AWS specific Properties/Parameters
         <table>
          <tr><u>**access_key_id**</u><tr/> <tr> your aws access key id<tr/>  
          <tr><u>**access_key**</u><tr/> <tr> your aws access key <tr/>  
          <tr><u>**key_name**</u><tr/> <tr> key pair name in aws.It defaults to 'aws'<tr/>  
        </table>  
        - ####GCE specific Properties/Parameters
         <table>
          <tr><u>**access_key_id**</u><tr/> <tr> your aws access key id<tr/>  
          <tr><u>**access_key**</u><tr/> <tr> your aws access key <tr/>  
          <tr><u>**key_name**</u><tr/> <tr> key pair name in aws.It defaults to 'aws'<tr/>  
        </table>  


##<u>ToDo</u>

- Reading credentials from .fog file (or supplied credentials file)
- DNS support for AWS & GCE
- Loadbalncer for AWS 7 GCE

##<u>Example Usage</u>

###<u>AWS</u>

* #### Create an AWS instance
    - with access_key and, access_key_id from ENV variable <br/>
     <code>
       puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                    provider => 'aws',
                                                                    ensure   => present,}"
     </code>

    - with access_key and/or access_key_id set in moudle ** NOT RECOMMENED ** <br/>
      <code>
        puppet apply --moudulepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                      provider      => 'aws',
                                                                      access_key_id => 'your aws access key id',
                                                                      access_key    => 'your aws access key',
                                                                      ensure        => present, }"
      </code>

* #### Stop an AWS instance
    - with access_key and, access_key_id from ENV variable <br/>
    <code> puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                        provider => 'aws',
                                                                        ensure   => stopped,}"
    </code>

    - with access_key and/or access_key_id set in moudle ** NOT RECOMMENED ** <br/>
    <code> puppet apply --moudulepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                         provider      => 'aws',
                                                                         access_key_id => 'your aws access key id',
                                                                         access_key    => 'your aws access key',
                                                                         ensure        => stopped, }"
    </code>

* #### Start an AWS instance
    - with access_key and, access_key_id from ENV variable <br/>
    <code> puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                        provider => 'aws',
                                                                        ensure   => running,}"
    </code>

    - with access_key and/or access_key_id set in moudle ** NOT RECOMMENED ** <br/>
    <code> puppet apply --moudulepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                         provider      => 'aws',
                                                                         access_key_id => 'your aws access key id',
                                                                         access_key    => 'your aws access key',
                                                                         ensure        => running, }"
    </code>

* #### Destroy an AWS instance
    - with access_key and, access_key_id from ENV variable <br/>
    <code> puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                       provider => 'aws',
                                                                       ensure   => absent,}"
    </code>

    - with access_key and/or access_key_id set in moudle ** NOT RECOMMENED ** <br/>
    <code> puppet apply --moudulepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                       provider      => 'aws',
                                                                       access_key_id => 'your aws access key id',
                                                                       access_key    => 'your aws access key',
                                                                       ensure        => abesent, }"
    </code>

###<u>GCE ( Google Compute Engine)</u>

* #### Create an GCE instance
    - with cleint_email and,key_location set in ENV variable <br/>
    <code> puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                        provider   => 'google',
                                                                        project_id => 'your google project id',
                                                                        ensure     => present,}"
    </code>

    - client_email and/or key_location set in moudle ** NOT RECOMMANDED ** <br/>
    <code> puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                        provider     => 'google',
                                                                        project_id   => 'your google project id',
                                                                        client_email => 'google client email from service account',
                                                                        key_location => 'google p12 key from service account',
                                                                        ensure       => present,}"

    <code/>

* #### Destroy an GCE instance
    - with cleint_email and,key_location set in ENV variable <br/>
    <code> puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                        provider   => 'google',
                                                                        project_id => 'your google project id',
                                                                        ensure     => absent,}"
    </code>

    - client_email and/or key_location set in moudle ** NOT RECOMMANDED ** <br/>
    <code> puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                        provider     => 'google',
                                                                        project_id   => 'your google project id',
                                                                        client_email => 'google client email from service account',
                                                                        key_location => 'google p12 key from service account',
                                                                        ensure       => absent,}"

    <code/>

* #### Stopping & Starting GCE instance
    - Currently stopping and, starting operations are synonym to absent & present operations
