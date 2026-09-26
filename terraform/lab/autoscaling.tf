resource "aws_launch_template" "app" {
  name = "aws-secure-portal-app-lt"

  image_id      = data.aws_ssm_parameter.al2023_arm64_ami.value
  instance_type = "t4g.micro"

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  user_data = filebase64("${path.module}/user_data.sh")

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = "gp3"
      volume_size           = 8
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "aws-secure-portal-asg-app"
      Project     = "aws-secure-portal"
      Environment = "lab"
      ManagedBy   = "Terraform"
    }
  }

  tags = {
    Name        = "aws-secure-portal-app-lt"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }

  update_default_version = true
}

resource "aws_autoscaling_group" "app" {
  name = "aws-secure-portal-asg"

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  health_check_type         = "ELB"
  health_check_grace_period = 120

  vpc_zone_identifier = [
    aws_subnet.this["app-private-a"].id,
    aws_subnet.this["app-private-b"].id
  ]

  target_group_arns = [
    aws_lb_target_group.app.arn
  ]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Default"
  }
}
