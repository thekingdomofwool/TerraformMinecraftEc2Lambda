# Overview 

# TerraformEc2Minecraft
You will need to change the user_data script if you use a different AMI -- the one I used is specific to Amazon Linux and Corretto. 

To allow ssh access via public/private keypair add the following resource block to main.tf: 

![image](https://user-images.githubusercontent.com/103598369/163509427-f03e4041-610f-481c-a894-9a826f93e807.png)

Then, add: key_name = "ssh-key" to the instance block in main.tf.

I, however, prefer to simply skip this part and rely on access via Instance Connect in the AWS console (see below)

# SSH from the AWS console (instance connect)
Search the following for the EC2_INSTANCE_CONNECT service, find the block that corresponds to whatever region your instance resides, and permit that IP address range via your security group on port 22.
https://ip-ranges.amazonaws.com/ip-ranges.json


# Minecraft Specifics 

SSH into the intance (see outputs to get the public IP) and add the following script to /etc/systemd/system/minecraft.service (or whatever you want to call this file): 

ExecStart=/usr/bin/java -Xmx1024M -Xms1024M -jar server.jar nogui


Then enable the service: 
chmod 664 /etc/systemd/system/minecraft.service
systemctl daemon-reload

# Lambda 

Adjust the cron expression to set the on-time for the server. 

# Something I Learned (among other things)
You need to have the uncompressed version of a file in the directory you're working in if you intend to pass a .zip version to Lambda. 

# How to adjust the time 
