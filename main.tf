terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create Lightsail Instance
resource "aws_lightsail_instance" "create_instance" {
  name         = "ubuntu-24-2cpu-2gb-instance"
  blueprint_id = "ubuntu_24_04"  # Blueprint ID for Ubuntu 24.04
  bundle_id    = "small_2_0"     # Bundle ID for 2 CPUs and 2 GB of RAM

  # Optional: Set the availability zone (can be left out for automatic selection)
  availability_zone = "us-east-1a"  # Optional: Set the availability zone

  # Tags for identification
  tags = {
    Name = "Ubuntu 24.04 Lightsail Instance"
  }
}

# Install Docker on the Lightsail Instance
resource "null_resource" "install_docker" {
  depends_on = [aws_lightsail_instance.create_instance]  # Ensures that Docker is installed after the instance is created

  provisioner "remote-exec" {
    inline = [
      # Update package list and install required packages for Docker
      "sudo apt-get update -y",
      "sudo apt-get install -y ca-certificates curl lsb-release gnupg",

      # Add Docker's official GPG key
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",

      # Add Docker repository to Apt sources
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

      # Install Docker and required packages
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",

      # Create Docker group if it doesn't exist and add the user
      "sudo groupadd docker || true",  # Ignore error if the group exists
      "sudo usermod -aG docker ubuntu",

      # Ensure Docker starts automatically and is running
      "sudo systemctl enable docker",
      "sudo systemctl start docker",

      # Test Docker installation by running hello-world
      "sudo docker run hello-world"
    ]

    # Connection details to the instance
    connection {
      type        = "ssh"
      host        = aws_lightsail_instance.create_instance.public_ip_address
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
  }
}
