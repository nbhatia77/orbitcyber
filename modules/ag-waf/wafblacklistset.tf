
resource "aws_waf_ipset" "WAFBlacklistSet" {
    name = "${var.customer} - Blacklist Set"
    ip_set_descriptors {
        type = "IPV4"
        value = "0.0.0.0/32"
    }
}
