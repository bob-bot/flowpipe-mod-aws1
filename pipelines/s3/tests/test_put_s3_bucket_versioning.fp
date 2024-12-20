pipeline "test_put_s3_bucket_versioning" {
  title       = "Test Put S3 Bucket Versioning"
  description = "Test the put_s3_bucket_versioning pipeline."

  tags = {
    folder = "Tests"
  }

  param "conn" {
    type        = connection.aws
    description = local.conn_param_description
    default     = connection.aws.default
  }

  param "region" {
    type        = string
    description = local.region_param_description
  }

  param "bucket" {
    type        = string
    description = "The name of the bucket."
    default     = "flowpipe-test-${uuid()}"
  }

  step "transform" "base_args" {
    output "base_args" {
      value = {
        conn   = param.conn
        region = param.region
        bucket = param.bucket
      }
    }
  }

  step "pipeline" "create_s3_bucket" {
    pipeline = pipeline.create_s3_bucket
    args     = step.transform.base_args.output.base_args
  }

  step "pipeline" "test_put_s3_bucket_versioning_enable_disable" {
    depends_on = [step.pipeline.create_s3_bucket]

    pipeline = pipeline.test_put_s3_bucket_versioning_enable_disable
    args     = step.transform.base_args.output.base_args

    # Ignore errors so we always delete
    error {
      ignore = true
    }
  }

  step "pipeline" "delete_s3_bucket" {
    if         = !is_error(step.pipeline.create_s3_bucket)
    depends_on = [step.pipeline.test_put_s3_bucket_versioning_enable_disable]

    pipeline = pipeline.delete_s3_bucket
    args     = step.transform.base_args.output.base_args
  }

  output "bucket" {
    description = "Bucket name used in the test."
    value       = param.bucket
  }

  output "test_results" {
    description = "Test results for each step."
    value = {
      "create_s3_bucket"                    = !is_error(step.pipeline.create_s3_bucket) ? "pass" : "fail: ${error_message(step.pipeline.create_s3_bucket)}"
      "enable_disable_s3_bucket_versioning" = step.pipeline.test_put_s3_bucket_versioning_enable_disable.output
      "delete_s3_bucket"                    = !is_error(step.pipeline.delete_s3_bucket) ? "pass" : "fail: ${error_message(step.pipeline.create_s3_bucket)}"
    }
  }

}

pipeline "test_put_s3_bucket_versioning_enable_disable" {
  title       = "Test Enable and Disable S3 Bucket Versioning"
  description = "Test enabling and disabling S3 bucket versioning."

  tags = {
    folder = "Tests"
  }

  param "region" {
    type        = string
    description = "The name of the Region."
  }

  param "conn" {
    type        = connection.aws
    description = local.conn_param_description
    default     = connection.aws.default
  }

  param "bucket" {
    type        = string
    description = "The name of the bucket."
    default     = "flowpipe-test-${uuid()}"
  }

  step "transform" "base_args" {
    output "base_args" {
      value = {
        conn   = param.conn
        region = param.region
        bucket = param.bucket
      }
    }
  }

  # New buckets have versioning disabled by default
  step "pipeline" "enable_s3_bucket_versioning" {
    pipeline = pipeline.put_s3_bucket_versioning
    args     = merge(step.transform.base_args.output.base_args, { versioning = true })
  }

  # The put command doesn't return the new state
  step "pipeline" "check_s3_bucket_versioning_enabled" {
    depends_on = [step.pipeline.enable_s3_bucket_versioning]

    pipeline = pipeline.get_s3_bucket_versioning
    args     = step.transform.base_args.output.base_args
  }

  step "pipeline" "disable_s3_bucket_versioning" {
    depends_on = [step.pipeline.check_s3_bucket_versioning_enabled]

    pipeline = pipeline.put_s3_bucket_versioning
    args     = merge(step.transform.base_args.output.base_args, { versioning = false })
  }

  # The put command doesn't return the new state
  step "pipeline" "check_s3_bucket_versioning_disabled" {
    depends_on = [step.pipeline.disable_s3_bucket_versioning]

    pipeline = pipeline.get_s3_bucket_versioning
    args     = step.transform.base_args.output.base_args
  }

  output "test_results" {
    description = "Test results for each step."
    value = {
      "enable_s3_bucket_versioning"         = !is_error(step.pipeline.enable_s3_bucket_versioning) ? "pass" : "fail: ${error_message(step.pipeline.enable_s3_bucket_versioning)}"
      "check_s3_bucket_versioning_enabled"  = !is_error(step.pipeline.check_s3_bucket_versioning_enabled) ? "pass" : "fail: ${error_message(step.pipeline.check_s3_bucket_versioning_enabled)}"
      "disable_s3_bucket_versioning"        = !is_error(step.pipeline.disable_s3_bucket_versioning) ? "pass" : "fail: ${error_message(step.pipeline.disable_s3_bucket_versioning)}"
      "check_s3_bucket_versioning_disabled" = !is_error(step.pipeline.check_s3_bucket_versioning_disabled) ? "pass" : "fail: ${error_message(step.pipeline.check_s3_bucket_versioning_disabled)}"
    }
  }

}
