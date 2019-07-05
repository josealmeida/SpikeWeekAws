provider "aws" {
  profile    = "josealmeida.nice"
  region     = "eu-west-2"
}

data "aws_ami" "spike_week_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["spike-week-aws-packer-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["508281263350"]
}

resource "aws_instance" "spike_week_ec2" {
  ami = "${data.aws_ami.spike_week_ami.id}"
  instance_type = "t2.micro"
  key_name = "spike-week-aws-key"
  provisioner "local-exec" {
    command = "echo ${aws_instance.spike_week_ec2.public_dns} > spike_week_ec2.txt"
  }
  tags = {
    Name = "spike_week_ec2"
  }
}

resource "aws_eip" "ip" {
  instance = aws_instance.spike_week_ec2.id
}

resource "aws_key_pair" "spike_week_aws_key" {
  key_name = "spike-week-aws-key"
  public_key = file("spike-week-aws-key.pub")
}

output "ami" {
  value = aws_instance.spike_week_ec2.ami
}
output "public_dns" {
  value = aws_eip.ip.public_dns
}
output "ssh_command" {
  value = "ssh -i spike-week-aws-key.pem ec2-user@${aws_eip.ip.public_dns}"
}

// TODO: EC2 security group config
// https://www.terraform.io/docs/providers/aws/r/security_group.html
// https://eu-west-2.console.aws.amazon.com/ec2/v2/home?region=eu-west-2#SecurityGroups:sort=groupId
// config source