output "region1" {
  value = var.region1
}

output "region2" {
  value = var.region2
}

output "r1_public_ip" {
  value       = aws_instance.r1.public_ip
  description = "Public IP of instance in region1"
}

output "r1_public_dns" {
  value       = aws_instance.r1.public_dns
  description = "Public DNS of instance in region1"
}

output "r2_public_ip" {
  value       = aws_instance.r2.public_ip
  description = "Public IP of instance in region2"
}

output "r2_public_dns" {
  value       = aws_instance.r2.public_dns
  description = "Public DNS of instance in region2"
}
