terraform {
  required_version = "1.3.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
  }
}

resource "aws_s3_bucket" "this" {
  bucket = "terraform-bucket-aaabbbccc"
  tags = {
    Name        = "Terraform_test_bucket"
    Environment = "Dev"
  }
}

resource "aws_wafv2_web_acl" "this" {
  name        = "rate-based-example"
  description = "Example of a Cloudfront rate based statement."
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "rule-1"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 10000
        aggregate_key_type = "IP"

        scope_down_statement {
          geo_match_statement {
            country_codes = ["US", "NL"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "example" {
  log_destination_configs = [aws_s3_bucket.this.arn]
  resource_arn            = aws_wafv2_web_acl.this.arn
  redacted_fields {
    single_header {
      name = "user-agent"
    }
  }
}