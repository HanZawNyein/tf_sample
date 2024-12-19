# variables.tf
variable "aws_access_key" {
  description = "The AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "The AWS secret key"
  type        = string
  sensitive   = true  # Mark the secret key as sensitive
}

variable "ssh_private_key_path" {
  type = string
}