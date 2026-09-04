##############
# Monitoring #
##############

# The alarm topic uses the AWS-managed SNS key; a CMK is unnecessary for these operational alerts.
#trivy:ignore:AVD-AWS-0095
#trivy:ignore:AVD-AWS-0136
resource "aws_sns_topic" "alarms" {
  count = var.enable_health_alarms && var.alarm_sns_topic_arn == null ? 1 : 0

  name = "${local.name}-alarms"

  tags = merge(local.common_tags, { Name = "${local.name}-alarms" })
}

resource "aws_sns_topic_subscription" "alarm_email" {
  for_each = var.enable_health_alarms && var.alarm_sns_topic_arn == null ? toset(var.alarm_email_addresses) : toset([])

  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_metric_alarm" "nat_instance_down" {
  for_each = var.enable_health_alarms ? local.asg_az_subnets : {}

  alarm_name          = "${local.name}-${each.key}-down"
  alarm_description   = "Triggers when the fck-nat instance in ${each.key} has no in-service instances"
  namespace           = "AWS/AutoScaling"
  metric_name         = "GroupInServiceInstances"
  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 5
  datapoints_to_alarm = 3
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nat_instance[each.key].name
  }

  alarm_actions = [local.alarm_topic_arn]
  ok_actions    = [local.alarm_topic_arn]

  tags = merge(local.common_tags, { Name = "${local.name}-${each.key}-down" })
}
