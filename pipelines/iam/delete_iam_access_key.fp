pipeline "delete_iam_access_key" {
  title       = "Delete IAM Access Key"
  description = "Deletes an IAM access key."

  param "conn" {
    type        = connection.aws
    description = local.conn_param_description
    default     = connection.aws.default
  }

  param "user_name" {
    type        = string
    description = "The name of the user whose access key you want to delete."
  }

  param "access_key_id" {
    type        = string
    description = "The access key ID for the access key ID you want to delete."
  }

  step "container" "create_access_key" {
    image = "public.ecr.aws/aws-cli/aws-cli"
    cmd = [
      "iam",
      "delete-access-key",
      "--user-name", "${param.user_name}",
      "--access-key-id", "${param.access_key_id}"
    ]
    env = param.conn.env
  }
}
