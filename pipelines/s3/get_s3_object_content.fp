pipeline "get_s3_object_content" {
  title       = "Get S3 Object Content"
  description = "Gets the content of an S3 object."

  param "region" {
    type        = string
    description = local.region_param_description
  }

  param "conn" {
    type        = connection.aws
    description = local.conn_param_description
    default     = connection.aws.default
  }

  param "bucket" {
    type        = string
    description = "S3 bucket name."
  }

  param "path_to_file" {
    type        = string
    description = "Path to S3 file."
  }

  step "container" "get_s3_object_content" {
    image = "public.ecr.aws/aws-cli/aws-cli"
    cmd   = ["s3", "cp", "s3://${param.bucket}/${param.path_to_file}", "-"]

    env = merge(param.conn.env, { AWS_REGION = param.region })
  }

  output "content" {
    description = "Object content."
    value       = step.container.get_s3_object_content.stdout
  }
}
