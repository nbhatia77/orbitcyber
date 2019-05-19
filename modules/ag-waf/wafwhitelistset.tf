
resource "aws_waf_ipset" "WAFWhitelistSet" {
    name = "${var.customer} - Whitelist Set"
    ip_set_descriptors {
        type = "IPV4"
        value = "0.0.0.0/32"
    }
}
