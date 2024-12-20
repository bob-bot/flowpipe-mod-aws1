pipeline "put_s3_bucket_public_access_block" {
  title       = "Put S3 Public Access Block"
  description = "Creates or modifies the PublicAccessBlock configuration for an Amazon S3 bucket."

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
    description = "The name of the S3 bucket."
  }

  # TODO: AWS defaults to false for all settings when not specified,
  # but we require each one to prevent accidentally turning off restrictions. Should they be required?

  param "block_public_acls" {
    type        = bool
    description = "Specifies whether Amazon S3 should block public access control lists (ACLs) for this bucket and objects in this bucket."
  }

  param "ignore_public_acls" {
    type        = bool
    description = "Specifies whether Amazon S3 should ignore public ACLs for this bucket and objects in this bucket."
  }

  param "block_public_policy" {
    type        = bool
    description = "Specifies whether Amazon S3 should block public bucket policies for this bucket."
  }

  param "restrict_public_buckets" {
    type        = bool
    description = "Specifies whether Amazon S3 should restrict public bucket policies for this bucket."
  }

  step "container" "put_s3_bucket_public_access_block" {
    image = "public.ecr.aws/aws-cli/aws-cli"

    cmd = concat(
      ["s3api", "put-public-access-block"],
      ["--bucket", param.bucket],
      ["--public-access-block-configuration", join(",", concat(
        param.block_public_acls != null ? ["BlockPublicAcls=${param.block_public_acls}"] : [],
        param.ignore_public_acls != null ? ["IgnorePublicAcls=${param.ignore_public_acls}"] : [],
        param.block_public_policy != null ? ["BlockPublicPolicy=${param.block_public_policy}"] : [],
        param.restrict_public_buckets != null ? ["RestrictPublicBuckets=${param.restrict_public_buckets}"] : []
      ))]
    )

    env = merge(param.conn.env, { AWS_REGION = param.region })
  }
}
