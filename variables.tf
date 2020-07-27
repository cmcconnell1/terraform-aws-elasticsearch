variable "aws_elasticsearch_domain" {
  type = "string"
}

variable "aws_elasticsearch_version" {
  type = "string"
}

variable "aws_elasticsearch_instance_type" {
  type = "string"
}

variable "aws_elasticsearch_cloudwatch_log_group" {
  type = "string"
}

variable "aws_elasticsearch_cloudwatch_log_resource_policy" {
  type = "string"
}

variable "aws_elasticsearch_route53_zone_id" {
  type        = "string"
  description = "Route53 DNS Zone ID to add hostname records for Elasticsearch domain and Kibana"
}

variable "aws_elasticsearch_route53_alias_ttl" {
  type        = "string"
  description = "Route53 DNS records TTL"
}

variable "aws_elasticsearch_route53_subdomain_name" {
  type        = "string"
}

variable "aws_elasticsearch_instance_count" {
  description = "Number of data nodes in the cluster"
}

variable "aws_elasticsearch_iam_role_arns" {
  type        = "list"
  default     = []
  description = "List of IAM role ARNs to permit access to the Elasticsearch domain"
}

variable "aws_elasticsearch_iam_authorizing_role_arns" {
  type        = "list"
  default     = []
  description = "List of IAM role ARNs to permit to assume the Elasticsearch user role"
}

variable "aws_elasticsearch_iam_actions" {
  type        = "list"
  default     = []
  description = "List of actions to allow for the IAM roles, _e.g._ `es:ESHttpGet`, `es:ESHttpPut`, `es:ESHttpPost`"
}

variable "aws_elasticsearch_zone_awareness_enabled" {
  type        = "string"
  description = "Enable zone awareness for Elasticsearch cluster"
}

variable "aws_elasticsearch_ebs_volume_size" {
  description = "use EBS volumes for data storage by specifying volume size in GB"
}

variable "aws_elasticsearch_ebs_volume_type" {
  type        = "string"
  description = "Storage type of EBS volumes"
}

variable "aws_elasticsearch_log_publishing_index_enabled" {
  type        = "string"
  description = "Specifies whether log publishing option for INDEX_SLOW_LOGS is enabled or not"
}

variable "aws_elasticsearch_log_publishing_search_enabled" {
  type        = "string"
  description = "Specifies whether log publishing option for SEARCH_SLOW_LOGS is enabled or not"
}

variable "aws_elasticsearch_log_publishing_application_enabled" {
  type        = "string"
  description = "Specifies whether log publishing option for ES_APPLICATION_LOGS is enabled or not"
}

variable "aws_elasticsearch_automated_snapshot_start_hour" {
  type        = "string"
  description = "Hour at which automated snapshots are taken, in UTC"
}

variable "aws_elasticsearch_dedicated_master_enabled" {
  type        = "string"
  description = "Indicates whether dedicated master nodes are enabled for the cluster"
}

variable "aws_elasticsearch_dedicated_master_count" {
  description = "Number of dedicated master nodes in the cluster"
}

variable "aws_elasticsearch_dedicated_master_type" {
  type        = "string"
  description = "Instance type of the dedicated master nodes in the cluster"
}

# if needed in the future
# https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-createupdatedomains.html#es-createdomain-configure-advanced-options
#variable "aws_elasticsearch_advanced_options" {
#  type        = "map"
#  default     = {}
#  description = "Key-value string pairs to specify advanced configuration options"
#}

variable "aws_elasticsearch_kibana_subdomain_name" {
  type        = "string"
  default     = "kibana"
  description = "The name of the subdomain for Kibana in the DNS zone (_e.g._ `kibana`, `ui`, `ui-es`, `search-ui`, `kibana.elasticsearch`)"
}

variable "aws_elasticsearch_create_iam_service_linked_role" {
  type        = "string"
  default     = "true"
  description = "Whether to create `AWSServiceRoleForAmazonElasticsearchService` service-linked role. Set it to `false` if you already have an ElasticSearch cluster created in the AWS account and AWSServiceRoleForAmazonElasticsearchService already exists. See https://github.com/terraform-providers/terraform-provider-aws/issues/5218 for more info"
}

variable "env_global_tags" {
  type = "map"
  default = {}
}