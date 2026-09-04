locals {
  alarm_topic_arn = var.alarm_sns_topic_arn != null ? var.alarm_sns_topic_arn : (
    var.enable_health_alarms ? aws_sns_topic.alarms[0].arn : null
  )
}
