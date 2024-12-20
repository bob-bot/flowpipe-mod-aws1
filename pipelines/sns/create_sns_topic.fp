pipeline "create_sns_topic" {
  title       = "Create SNS Topic"
  description = "Creates an Amazon SNS topic."

  param "region" {
    type        = string
    description = local.region_param_description
  }

  param "conn" {
    type        = connection.aws
    description = local.conn_param_description
    default     = connection.aws.default
  }

  param "name" {
    type        = string
    description = "The name of the Amazon SNS topic to create."
  }

  step "container" "create_sns_topic" {
    image = "public.ecr.aws/aws-cli/aws-cli"

    cmd = concat(
      ["sns", "create-topic"],
      ["--name", param.name],
    )

    env = merge(param.conn.env, { AWS_REGION = param.region })
  }

  output "topic_arn" {
    description = "The Amazon Resource Name (ARN) assigned to the created topic."
    value       = jsondecode(step.container.create_sns_topic.stdout).TopicArn
  }
}
