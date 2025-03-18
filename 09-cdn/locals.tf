locals {
  resource_name = "${var.project_name}-${var.environment}"      #expense-dev
  acm_https_cert_arn = data.aws_ssm_parameter.acm_https_cert_arn.value
}

  # db_subnet_ids = split(",", data.aws_ssm_parameter.database_subnet_ids[*].value)