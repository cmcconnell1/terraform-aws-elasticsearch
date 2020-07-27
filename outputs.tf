output "security_group_id" {
  value       = ["${data.aws_security_group.elasticsearch.id}"]
  description = "Security Group ID for access to the Elasticsearch domain"
}

output "domain_arn" {
  value       = "${join("", aws_elasticsearch_domain.es.*.arn)}"
  description = "ARN of the Elasticsearch domain"
}

output "domain_id" {
  value       = "${join("", aws_elasticsearch_domain.es.*.domain_id)}"
  description = "Unique identifier for the Elasticsearch domain"
}

output "domain_endpoint" {
  value       = "${join("", aws_elasticsearch_domain.es.*.endpoint)}"
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
}

output "kibana_endpoint" {
  value       = "${join("", aws_elasticsearch_domain.es.*.kibana_endpoint)}"
  description = "Domain-specific endpoint for Kibana without https scheme"
}

output "domain_hostname" {
  value       = "elastic.${var.aws_elasticsearch_route53_subdomain_name}"
  description = "Elasticsearch domain hostname to submit index, search, and data upload requests"
}

output "kibana_hostname" {
  value       = "${var.aws_elasticsearch_kibana_subdomain_name}"
  value       = "kibana.${var.aws_elasticsearch_route53_subdomain_name}"
  description = "Kibana hostname"
}

#output "elasticsearch_user_iam_role_name" {
#  value       = "${join(",", aws_iam_service_linked_role.es.*.name)}"
#  description = "The name of the IAM role to allow access to Elasticsearch cluster"
#}
#
#output "elasticsearch_user_iam_role_arn" {
#  value       = "${join(",",aws_iam_role.elasticsearch_user.*.arn)}"
#  description = "The ARN of the IAM role to allow access to Elasticsearch cluster"
#}
