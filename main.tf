# ============================================================================
# Terraform Route53 DNS Record Automation
#
# This configuration imports DNS records from CSV files using a Python script
# (`parse_dns_csvs.py`) and provisions them in AWS Route53. Each record type
# is handled dynamically using the external data source and for_each.
#
# Best Practices:
# - Ensure `parse_dns_csvs.py` outputs a JSON structure matching the expected keys.
# - Use remote state (e.g., S3 backend) for team collaboration and disaster recovery.
# - Protect sensitive data (e.g., credentials) and avoid hardcoding secrets.
# - Use version control for all infrastructure code.
# - Test changes in a non-production environment before applying to production.
# - Use `terraform plan` to review changes before applying.
# - Keep provider and module versions up to date.
#
# For more details, see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
# ============================================================================

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.0"
    }
  }
  # Uncomment and configure the backend below for remote state management
  # backend "s3" {
  #   bucket = "my-terraform-state-bucket"
  #   key    = "route53/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region
}

data "external" "dns_records" {
  program = ["python3", var.python_script_path]
}

# --- A Records ---
resource "aws_route53_record" "a_record" {
  for_each = try({ for rec in data.external.dns_records.result.a_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "A"
  ttl      = tonumber(each.value.ttl)
  records  = [each.value.ip_addr]
}

# --- AAAA Records ---
resource "aws_route53_record" "aaaa_record" {
  for_each = try({ for rec in data.external.dns_records.result.aaaa_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "AAAA"
  ttl      = tonumber(each.value.ttl)
  records  = [each.value.ipv6_addr]
}

# --- CNAME Records ---
resource "aws_route53_record" "cname_record" {
  for_each = try({ for rec in data.external.dns_records.result.cname_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "CNAME"
  ttl      = tonumber(each.value.ttl)
  records  = [each.value.target_name]
}

# --- ALIAS Records (for AWS ELB, etc.) ---
resource "aws_route53_record" "a_alias_record" {
  for_each = try({ for rec in data.external.dns_records.result.a_alias_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "A"
  alias {
    name                   = each.value.alias_target_dns
    zone_id                = each.value.alias_hosted_zone_id
    evaluate_target_health = false
  }
}

# --- TXT Records ---
resource "aws_route53_record" "txt_record" {
  for_each = try({ for rec in data.external.dns_records.result.txt_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "TXT"
  ttl      = tonumber(each.value.ttl)
  records  = [each.value.txt_value]
}

# --- MX Records ---
resource "aws_route53_record" "mx_record" {
  for_each = try({ for rec in data.external.dns_records.result.mx_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "MX"
  ttl      = tonumber(each.value.ttl)
  # MX expects priority and mail server separated by a space, as a single string.
  records = [format("%s %s", each.value.priority, each.value.mail_server)]
}

# --- NS Records ---
resource "aws_route53_record" "ns_record" {
  for_each = try({ for rec in data.external.dns_records.result.ns_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "NS"
  ttl      = tonumber(each.value.ttl)
  records  = [each.value.ns_server]
}

# --- SRV Records ---
resource "aws_route53_record" "srv_record" {
  for_each = try({ for rec in data.external.dns_records.result.srv_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "SRV"
  ttl      = tonumber(each.value.ttl)
  # SRV expects priority weight port target, all as one string.
  records = [format("%s %s %s %s", each.value.priority, each.value.weight, each.value.port, each.value.target)]
}

# --- PTR Records ---
resource "aws_route53_record" "ptr_record" {
  for_each = try({ for rec in data.external.dns_records.result.ptr_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "PTR"
  ttl      = tonumber(each.value.ttl)
  records  = [each.value.ptr_target]
}

# --- CAA Records ---
resource "aws_route53_record" "caa_record" {
  for_each = try({ for rec in data.external.dns_records.result.caa_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "CAA"
  ttl      = tonumber(each.value.ttl)
  # CAA format: flags tag value
  records = [format("%s %s %s", each.value.flags, each.value.tag, each.value.value)]
}

# --- SPF Records (as TXT) ---
resource "aws_route53_record" "spf_record" {
  for_each = try({ for rec in data.external.dns_records.result.spf_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "TXT"
  ttl      = tonumber(each.value.ttl)
  records  = [each.value.spf_value]
}

# --- DMARC Records (as TXT) ---
resource "aws_route53_record" "dmarc_record" {
  for_each = try({ for rec in data.external.dns_records.result.dmarc_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "TXT"
  ttl      = tonumber(each.value.ttl)
  records  = [each.value.txt_value]
}
# --- SOA Records ---
resource "aws_route53_record" "soa_record" {
  for_each = try({ for rec in data.external.dns_records.result.soa_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "SOA"
  ttl      = tonumber(each.value.ttl)
  records  = [format("%s %s %s %s %s %s %s", each.value.mname, each.value.rname, each.value.serial, each.value.refresh, each.value.retry, each.value.expire, each.value.minimum)]
}
# --- NAPTR Records ---
resource "aws_route53_record" "naptr_record" {
  for_each = try({ for rec in data.external.dns_records.result.naptr_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "NAPTR"
  ttl      = tonumber(each.value.ttl)
  # NAPTR format: order preference flags service regexp replacement
  records = [format("%s %s %s %s %s %s", each.value.order, each.value.preference, each.value.flags, each.value.service, each.value.regexp, each.value.replacement)]
}
# --- TLSA Records ---
resource "aws_route53_record" "tlsa_record" {
  for_each = try({ for rec in data.external.dns_records.result.tlsa_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "TLSA"
  ttl      = tonumber(each.value.ttl)
  # TLSA format: usage selector matching
  records = [format("%s %s %s", each.value.usage, each.value.selector, each.value.matching)]
}
# --- SSHFP Records ---
resource "aws_route53_record" "sshfp_record" {
  for_each = try({ for rec in data.external.dns_records.result.sshfp_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "SSHFP"
  ttl      = tonumber(each.value.ttl)
  # SSHFP format: algorithm type fingerprint
  records = [format("%s %s %s", each.value.algorithm, each.value.type, each.value.fingerprint)]
}
# --- URI Records ---
# Note: URI records are not supported by AWS Route53
# resource "aws_route53_record" "uri_record" {
#   for_each = try({ for rec in data.external.dns_records.result.uri_records : rec.record_name => rec }, {})
#   zone_id  = each.value.zone_id
#   name     = each.value.record_name
#   type     = "URI"
#   ttl      = tonumber(each.value.ttl)
#   # URI format: priority weight target
#   records = [format("%s %s %s", each.value.priority, each.value.weight, each.value.target)]
# }

# --- LOC Records ---
# Note: LOC records are not supported by AWS Route53
# resource "aws_route53_record" "loc_record" {
#   for_each = try({ for rec in data.external.dns_records.result.loc_records : rec.record_name => rec }, {})
#   zone_id  = each.value.zone_id
#   name     = each.value.record_name
#   type     = "LOC"
#   ttl      = tonumber(each.value.ttl)
#   # LOC format: version size horiz_precision vert_precision latitude longitude altitude
#   records = [format("%s %s %s %s %s %s %s", each.value.version, each.value.size, each.value.horiz_precision, each.value.vert_precision, each.value.latitude, each.value.longitude, each.value.altitude)]
# }

# --- CERT Records ---
# Note: CERT records are not supported by AWS Route53
# resource "aws_route53_record" "cert_record" {
#   for_each = try({ for rec in data.external.dns_records.result.cert_records : rec.record_name => rec }, {})
#   zone_id  = each.value.zone_id
#   name     = each.value.record_name
#   type     = "CERT"
#   ttl      = tonumber(each.value.ttl)
#   # CERT format: flags tag value
#   records = [format("%s %s %s", each.value.flags, each.value.tag, each.value.value)]
# }
# --- SVCB Records ---
resource "aws_route53_record" "svc_record" {
  for_each = try({ for rec in data.external.dns_records.result.svcb_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "SVCB"
  ttl      = tonumber(each.value.ttl)
  # SVCB format: priority params
  records = [format("%s %s", each.value.priority, each.value.params)]
}
# --- HTTPS Records ---
resource "aws_route53_record" "https_record" {
  for_each = try({ for rec in data.external.dns_records.result.https_records : rec.record_name => rec }, {})
  zone_id  = each.value.zone_id
  name     = each.value.record_name
  type     = "HTTPS"
  ttl      = tonumber(each.value.ttl)
  # HTTPS format: priority params
  records = [format("%s %s", each.value.priority, each.value.params)]
}

# TODO: If you add new DNS record types, update both parse_dns_csvs.py and this file accordingly.
