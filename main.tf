

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }

  github_subject = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
}



# -------------------------
# CodeDeploy
# -------------------------
resource "aws_codedeploy_app" "php" {
  name             = "${var.project_name}-application"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "php" {
  app_name              = aws_codedeploy_app.php.name
  deployment_group_name = "${var.project_name}-production"
  service_role_arn      = aws_iam_role.codedeploy.arn

  deployment_config_name = var.deployment_config_name

  autoscaling_groups = [
    aws_autoscaling_group.app.name
  ]

  auto_rollback_configuration {
    enabled = true
    events = [
      "DEPLOYMENT_FAILURE",
      "DEPLOYMENT_STOP_ON_ALARM",
      "DEPLOYMENT_STOP_ON_REQUEST"
    ]
  }

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.app.name
    }
  }

  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  # CodeDeploy installs lifecycle hooks into the ASG. New scale-out
  # instances receive the latest successful revision automatically.
  #autoscaling_groups = [aws_autoscaling_group.app.name]
}

# -------------------------
# Route 53
# -------------------------



data "aws_route53_zone" "selected" {
  count        = var.route53_zone_name != "" ? 1 : 0
  name         = var.route53_zone_name
  private_zone = false
}

resource "aws_route53_record" "app_primary" {
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = var.website_hostname
  type    = "A"

  set_identifier = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_health_check" "primary" {
  fqdn              = aws_lb.app.dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health/ready"
  request_interval  = 30
  failure_threshold = 3
}
# resource "aws_route53_record" "app_secondary" {
#   zone_id = data.aws_route53_zone.selected[0].zone_id
#   name    = var.website_hostname
#   type    = "A"

#   set_identifier = "secondary"

#   failover_routing_policy {
#     type = "SECONDARY"
#   }

#   alias {
#     name                   = aws_lb.app.dns_name
#     zone_id                = aws_lb.app.zone_id
#     evaluate_target_health = true
#   }
# }