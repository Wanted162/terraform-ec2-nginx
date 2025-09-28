variable "region1" {
  description = "Region for instance 1"
  type        = string
  default     = "ap-south-1" # Mumbai
}

variable "region2" {
  description = "Region for instance 2"
  type        = string
  default     = "us-west-2"  # Oregon
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair (must exist in both regions)"
  type        = string
  default     = "tf-nginx-key"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH (replace with your public IP for security)"
  type        = string
  default     = "0.0.0.0/0"
}
