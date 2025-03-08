packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ssh_username  = "ubuntu"
  ami_name      = "packer-ansible-nginx"
  instance_type = "t2.micro"
  region        = "us-west-2"

  source_ami_filter {
    filters = {
      # Using a wildcard filter for Ubuntu 24.04 AMIs
      name                = "*24.04*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "ansible" {
    user = var.ssh_username
    playbook_file   = "../ansible/playbook.yml"
    extra_arguments = ["-e", "ANSIBLE_HOST_KEY_CHECKING=False"]
  }
}
