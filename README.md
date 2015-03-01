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
- it can **create** the AWS or GCE instance
- it can **bootstrap** the AWS or GCE instnace

##<u>Supported Type</u>  
- cloud_machine  
  - Type Properties/Parameters  
    - Common for both AWS & GCE provider  
      - **provider**: currently supports aws and, google provider  
      - **ensure**   :current ensure-able supports, present,running,stopped and absent with present as a default value  
      - **bootstrap**: possible values are true/false and it defaults to false, set it to true if you wish to bootstrap your instance  
      - **bootstrap_file**: Required/Useful when bootstrap is set to true, this is location of your bootstrap script  
      - **ssh_public_key**: This is location for the public ssh key , used to connect to a machine during bootstrapping.It defaults to  
         ~/.ssh/aws.pub for AWS  
         ~/.ssh/google.pub  for GCE  
      - **ssh_private_key**: This is location for the private ssh key , used to connect to a machine during bootstrapping.It defaults to  
          ~/.ssh/aws for AWS  
          ~/.ssh/google  for GCE  
      - **bootstrap_user**: This is a bootstrapping user we are going to use and it defaults to **ubuntu** for both AWS & GCE
      - **template**: This is a image that we want to boot our instance with,it defaults to
         ami-f0b11187 for AWS
         ubuntu-1410-utopic-v20150202 for GCE
      - **template_type** : This is a image type that we want to boot our instance with, it defaults to
         t2.micro for AWS
         f1-mirco for GCE
      - **region**: Region where you want to create an instance.It defaults to
         eu-west-1 for AWS
         europe-west1-b for GCE

    - AWS specific Properties/Parameters
      - **access_key_id**: your aws access key id, which can be set via ENV variable as well  
      - **access_key**: your aws access key, which can be set via ENV cariable as well
      - **key_name**: AWS key pair name in.It defaults to 'aws'  
      
    - GCE specific Properties/Parameters
      - **project_id**: your Google project ID 
      - **client_email**: Email ID of your service account for GCE, can ve set via ENV variable
      - **disk_size**: disk size of an instance in GCE ,it defaults to 10GB
      - **key_location**: Location of your google p12 key, can be set via ENV variable.  Please note that you will need to remove the passphrase from this p12 key


##<u>ToDo</u>
- Reading credentials from .fog file (or supplied credentials file)
- DNS support for AWS & GCE
- Loadbalncer for AWS 7 GCE
- Add support for puppet resource cloud_machine , with an appropriate self.instances in providers
- Remove code dubpliation in Provider 

##<u>Example Usage</u>

###<u>AWS</u>
- Create an AWS instance
  - with access_key and, access_key_id from ENV variable  
   ```
    puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                 provider => 'aws',
                                                                 ensure   => present,
                                                              }"
    ```

  - with access_key and/or access_key_id set in moudle **NOT RECOMMENED**
   ```
    puppet apply --moudulepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                  provider      => 'aws',
                                                                  access_key_id => 'your aws access key id',
                                                                  access_key    => 'your aws access key',
                                                                  ensure        => present,
                                                                }"
    ```
- Stop an AWS instance
  - with access_key and, access_key_id from ENV variable <br/>
   ```
    puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                 provider => 'aws',
                                                                 ensure   => stopped,
                                                               }"
   ```
  - with access_key and/or access_key_id set in moudle **NOT RECOMMENED**
   ```
    puppet apply --moudulepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                  provider      => 'aws',
                                                                  access_key_id => 'your aws access key id',
                                                                  access_key    => 'your aws access key',
                                                                  ensure        => stopped, 
                                                                }"
   ```
- Start an AWS instance
  - with access_key and, access_key_id from ENV variable
   ```
    puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                 provider => 'aws',
                                                                 ensure   => running,
                                                               }"
   ```

  - with access_key and/or access_key_id set in moudle **NOT RECOMMENED**  
   ```
    puppet apply --moudulepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                  provider      => 'aws',
                                                                  access_key_id => 'your aws access key id',
                                                                  access_key    => 'your aws access key',
                                                                  ensure        => running, 
                                                                }"
    ```
- Destroy an AWS instance
  - with access_key and, access_key_id from ENV variable  
   ```
    puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                 provider => 'aws',
                                                                 ensure   => absent,
                                                               }"
    ```
  - with access_key and/or access_key_id set in moudle **NOT RECOMMENED *
   ```
    puppet apply --moudulepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                  provider      => 'aws',
                                                                  access_key_id => 'your aws access key id',
                                                                  access_key    => 'your aws access key',
                                                                  ensure        => abesent,
                                                                }"
   ```
- Bootstrap an AWS instance
  - with access_key and, access_key_id from ENV variable  
   ```
    puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                 provider       => 'aws',
                                                                 bootstrap      => true,
                                                                 bootstrap_file => './bootstrap.sh',
                                                                 ensure         => present,
                                                               }"
    ```
  - with access_key and/or access_key_id set in moudle **NOT RECOMMENED *
   ```
    puppet apply --moudulepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                  provider       => 'aws',
                                                                  access_key_id  => 'your aws access key id',
                                                                  access_key     => 'your aws access key',
                                                                  bootstrap      => true,
                                                                  bootstrap_file => './bootstrap.sh'
                                                                  ensure         => abesent,
                                                                }"
   ```
###<u>GCE ( Google Compute Engine)</u>
- Create a GCE instance
  - with cleint_email and,key_location set in ENV variable
   ```
    puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                 provider   => 'google',
                                                                 project_id => 'your google project id',
                                                                 ensure     => present,
                                                               }"
   ```
  - with client_email and/or key_location set in moudle **NOT RECOMMANDED**  
   ```
    puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                 provider     => 'google',
                                                                 project_id   => 'your google project id',
                                                                 client_email => 'google client email from service account',
                                                                 key_location => 'google p12 key from service account',
                                                                 ensure       => present,
                                                               }"

   ```

- Destroy a GCE instance
  - with cleint_email and,key_location set in ENV variable
   ```
    puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                 provider   => 'google',
                                                                 project_id => 'your google project id',
                                                                 ensure     => absent,
                                                               }"
   ```

  - with client_email and/or key_location set in moudle **NOT RECOMMANDED**
   ```
    puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                 provider     => 'google',
                                                                 project_id   => 'your google project id',
                                                                 client_email => 'google client email from service account',
                                                                 key_location => 'google p12 key from service account',
                                                                 ensure       => absent,
                                                               }"
   ```
- Stopping & Starting GCE instance
  - Currently stopping and, starting operations are synonym to absent & present operations
 
- Bootstrap a GCE instance
  - with cleint_email and,key_location set in ENV variable
   ```
    puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                 provider       => 'google',
                                                                 project_id     => 'your google project id',
                                                                 bootstrap      => true,
                                                                 bootstrap_file => './bootstrap.sh',
                                                                 ensure         => absent,
                                                               }"
   ```

  - with client_email and/or key_location set in moudle **NOT RECOMMANDED**
   ```
    puppet apply --moudlepath=/moudle/path -e "cloud_machine {'test_machine':
                                                                 provider       => 'google',
                                                                 project_id     => 'your google project id',
                                                                 client_email   => 'google client email from service account',
                                                                 key_location   => 'google p12 key from service account',
                                                                 bootstrap      => true,
                                                                 bootstrap_file => './bootstrap.sh',
                                                                 ensure         => absent,
                                                               }"
   ```
