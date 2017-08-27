provider "aws" {
  region  = "${var.aws_region}"
  #profile =  "${var.aws_profile}"
  access_key="AKIAIEF435AR52ZZ6K3Q"
  secret_key="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"
  
}

#IAM - not required

#VPC

resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
}

#Internet Gatway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

#Public route table

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internet_gateway.id}"
        }
  tags {
        Name = "public"
  }
}
#Private route table not_required

#Subnets
#public 

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1d"
  
  tags {
       Name = "public"
 }

}

resource "aws_subnet" "public2" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  
  tags {
       Name = "public2"
 }

}

#private   not_required
#RDS  not_required

# Subnet Associations

resource "aws_route_table_association" "public1_assoc"{
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}


resource "aws_route_table_association" "public2_assoc"{
  subnet_id = "${aws_subnet.public2.id}"
  route_table_id = "${aws_route_table.public.id}"
}


#Security Group

resource "aws_security_group" "public" {
  name = "security_group_public"
  description = "used for the public instances"
  vpc_id = "${aws_vpc.vpc.id}"

  #SSH
   ingress {
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     # Limiting the ssh access to the local IP
     cidr_blocks  = ["0.0.0.0/0"]
     }
    
  #HTTP
    ingress {
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]		
     }
   
   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
     }  
}

#Key_Pair

resource "aws_key_pair" "auth" {
  key_name = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}


#compute
 #VM

resource "aws_instance" "flask" {
  instance_type = "${var.flask_instance_type}"
  ami = "${var.flask_ami}"
  tags {
       Name= "flask"
  }
  key_name = "${aws_key_pair.auth.id}"
  user_data = "${file("user_data.tpl")}"
  vpc_security_group_ids = ["${aws_security_group.public.id}"]
  subnet_id = "${aws_subnet.public.id}"
  

  provisioner "local-exec" {
      command = <<EOD
  cat > aws_hosts << EOF
  [flask]
  ${aws_instance.flask.public_ip}
  #EOF
  EOD
  }

# ansible playbook
# run the ansible playbook against the VM to deploy the webapp
  provisioner "local-exec" {
      command = "sleep 6m && ansible-playbook -vv -i aws_hosts flask_python.yaml"
  }

}

# load_balancer
# launch_configuration
# Autoscaling
# route53
