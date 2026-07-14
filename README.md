###############################################################
# Outputs
# Exibe informações importantes após a criação da infraestrutura.
###############################################################

output "ec2_public_ip" {

  description = "Endereço IP público da instância EC2"

  value = aws_instance.atividade3_ec2.public_ip

}

output "load_balancer_dns" {

  description = "DNS público do Application Load Balancer"

  value = aws_lb.atividade3_alb.dns_name

}

output "rds_endpoint" {

  description = "Endpoint do banco de dados"

  value = aws_db_instance.atividade3_rds.endpoint

}
