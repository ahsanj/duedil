# AWS Credentails

vim ~/.aws/credentials

[profile_name]

access_key= secret_key=

export AWS_DEFAULT_PROFILE=profile_name

Also

- ssh-agent bash
- ssh-add ~/.ssh/id_rsa

Install Terraform

https://www.terraform.io/intro/getting-started/install.html


Clone this repo

- terraform plan
- terrraform apply

I have not added the domain to route53 so please update the /etc/hosts file with the following entry to access the webapp 

publicIP helloworld.com 

