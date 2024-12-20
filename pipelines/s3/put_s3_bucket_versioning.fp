pipeline "put_s3_bucket_versioning" {
  title       = "Put S3 Bucket Versioning"
  description = "Sets the versioning state of an existing bucket."

  tags = {
    recommended = "true"
  }

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
    description = "The bucket name."
  }

  param "versioning" {
    type        = bool
    description = "The versioning state of the bucket."
  }

  step "container" "put_s3_bucket_versioning" {
    image = "public.ecr.aws/aws-cli/aws-cli"

    cmd = concat(
      ["s3api", "put-bucket-versioning", "--bucket", param.bucket, "--versioning-configuration"],
      param.versioning ? ["Status=Enabled"] : ["Status=Suspended"],
    )

    env = merge(param.conn.env, { AWS_REGION = param.region })
  }
}
