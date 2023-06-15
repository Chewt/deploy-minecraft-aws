output "intance_public_ip" {
    description = "Public IP address of the minecraft server"
    value = aws_instance.app_server.public_ip
}
