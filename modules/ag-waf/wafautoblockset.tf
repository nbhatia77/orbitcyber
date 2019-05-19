
resource "aws_waf_ipset" "WAFAutoBlockSet" {
    name = "${var.customer} - Auto Block Set"
    ip_set_descriptors {
        type = "IPV4"
        value = "0.0.0.0/32"
    }
}
