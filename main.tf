# AWS Elasticsearch SaaS
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

#############################################################
# locals
#############################################################
locals {
  common_tags = {
    domain = "${var.aws_elasticsearch_domain}"
    environment = "${var.aws_elasticsearch_domain}"
  }

}

#############################################################
# Data source to get VPC-ID
#############################################################
data "terraform_remote_state" "main_vpc" {
  backend = "s3"

  config = {
    bucket         = "terradatum-terraform-state"
    encrypt        = "true"
    region         = "us-west-2"
    dynamodb_table = "terradatum-terraform-locks"
    key            = "dev-usw2/main-vpc/terraform.tfstate"
  }
}

######################################################################## 
# get stuff and create data resources
######################################################################## 
data "aws_subnet_ids" "private-2a" {
  vpc_id = "${data.terraform_remote_state.main_vpc.main_vpc_id}"

  tags {
    Name = "eks-dev-private-us-west-2a"
  }
}
data "aws_subnet_ids" "private-2b" {
  vpc_id = "${data.terraform_remote_state.main_vpc.main_vpc_id}"

  tags {
    Name = "eks-dev-private-us-west-2b"
  }
}

data "aws_security_group" "elasticsearch" {
  vpc_id = "${data.terraform_remote_state.main_vpc.main_vpc_id}"

  tags = {
    Name = "elasticsearch-dev-vpc"
  }
}

# ref: 
# https://www.terraform.io/docs/providers/aws/r/iam_service_linked_role.html
# https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/slr-es.html
# https://www.terraform.io/docs/providers/aws/r/elasticsearch_domain.html
#resource "aws_iam_service_linked_role" "es" {
#  aws_service_name = "es.amazonaws.com"
#  description = "${var.aws_elasticsearch_domain} AWS Elasticsearch SaaS Service Linked Role"
#}
# https://github.com/terraform-providers/terraform-provider-aws/issues/5218
# note the TF resource does not support tags
resource "aws_iam_service_linked_role" "es" {
  count            = "${var.aws_elasticsearch_create_iam_service_linked_role == "true" ? 1 : 0}"
  aws_service_name = "es.amazonaws.com"
  description      = "${var.aws_elasticsearch_domain} AWSServiceRoleForAmazonElasticsearchService Service-Linked Role"
}

resource "aws_elasticsearch_domain" "es" {
  #depends_on = ["aws_iam_service_linked_role.es"]
  domain_name           = "${var.aws_elasticsearch_domain}"
  elasticsearch_version = "${var.aws_elasticsearch_version}"

  ebs_options {
    ebs_enabled = "${var.aws_elasticsearch_ebs_volume_size > 0 ? true : false}"
    volume_size = "${var.aws_elasticsearch_ebs_volume_size}"
    volume_type = "${var.aws_elasticsearch_ebs_volume_type}"
  }

  cluster_config {
    instance_type            = "${var.aws_elasticsearch_instance_type}"
    instance_count           = "${var.aws_elasticsearch_instance_count}"
    dedicated_master_enabled = "${var.aws_elasticsearch_dedicated_master_enabled}"
    dedicated_master_type    = "${var.aws_elasticsearch_dedicated_master_type}"
    dedicated_master_count   = "${var.aws_elasticsearch_dedicated_master_count}"
    zone_awareness_enabled   = "${var.aws_elasticsearch_zone_awareness_enabled}"
  }

  vpc_options {
    subnet_ids =  ["${data.aws_subnet_ids.private-2a.ids}", "${data.aws_subnet_ids.private-2b.ids}"]
    security_group_ids = ["${data.aws_security_group.elasticsearch.id}"]
  }

# https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-createupdatedomains.html#es-createdomain-configure-advanced-options
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  log_publishing_options {
    enabled                  = "${var.aws_elasticsearch_log_publishing_index_enabled}"
    log_type                 = "INDEX_SLOW_LOGS"
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.elastic.arn}"
  }

  log_publishing_options {
    enabled                  = "${var.aws_elasticsearch_log_publishing_search_enabled}"
    log_type                 = "SEARCH_SLOW_LOGS"
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.elastic.arn}"
  }

  log_publishing_options {
    enabled                  = "${var.aws_elasticsearch_log_publishing_application_enabled}"
    log_type                 = "ES_APPLICATION_LOGS"
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.elastic.arn}"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.aws_elasticsearch_domain}/*"
        }
    ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = "${var.aws_elasticsearch_automated_snapshot_start_hour}"
  }

  #tags = {
  #  domain = "${var.aws_elasticsearch_domain}"
  #  description = "Managed by Terraform"
  #  environment = "${var.aws_elasticsearch_domain}"
  #}
  tags = "${merge( local.common_tags, var.env_global_tags)}"

  depends_on = [
    "aws_iam_service_linked_role.es",
  ]
}

#############################################################
# Log Publishing to CloudWatch Logs
# ref: https://www.terraform.io/docs/providers/aws/r/elasticsearch_domain.html
#############################################################
resource "aws_cloudwatch_log_group" "elastic" {
  name = "${var.aws_elasticsearch_cloudwatch_log_group}"
}

resource "aws_cloudwatch_log_resource_policy" "elastic" {
  policy_name = "${var.aws_elasticsearch_cloudwatch_log_resource_policy}"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

# Elasticsearch domain hostname to submit index, search, and data upload requests
resource "aws_route53_record" "aws-elasticsearch-dev-terradatum-com-CNAME" {
    name    = "elastic.${var.aws_elasticsearch_route53_subdomain_name}"
    records   = ["${aws_elasticsearch_domain.es.*.endpoint}"]
    zone_id = "${var.aws_elasticsearch_route53_zone_id}"
    ttl     = "${var.aws_elasticsearch_route53_alias_ttl}"
    type    = "CNAME"
}

resource "aws_route53_record" "aws-kibana-dev-terradatum-com-CNAME" {
    name    = "kibana.${var.aws_elasticsearch_route53_subdomain_name}"
    #records   = ["${aws_elasticsearch_domain.es.*.kibana_endpoint}"]
    records   = ["${aws_elasticsearch_domain.es.*.endpoint}"]
    zone_id = "${var.aws_elasticsearch_route53_zone_id}"
    ttl     = "${var.aws_elasticsearch_route53_alias_ttl}"
    type    = "CNAME"
}
