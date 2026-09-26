output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "website_url" {
  value = var.enable_https ? "https://${aws_lb.app.dns_name}" : "http://${aws_lb.app.dns_name}"
}

output "deployment_bucket" {
  value = aws_s3_bucket.deployments.bucket
}

output "codedeploy_application" {
  value = aws_codedeploy_app.php.name
}

output "codedeploy_deployment_group" {
  value = aws_codedeploy_deployment_group.php.deployment_group_name
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "rds_endpoint" {
  value     = aws_db_instance.mysql.address
  sensitive = true
}

output "asg_name" {
  value = aws_autoscaling_group.app.name
}

output "route53_hostname" {
  value = var.website_hostname != "" && var.route53_zone_name != "" ? "http://${var.website_hostname}" : "Route53 record not configured"
}
