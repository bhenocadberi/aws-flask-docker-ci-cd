output "flask_app_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.flask_app.public_ip
}
