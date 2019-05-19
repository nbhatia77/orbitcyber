
resource "aws_waf_ipset" "WAFBadBotSet" {
    name = "${var.customer} - IP Bad Bot Set"
    ip_set_descriptors {
        type = "IPV4"
        value = "0.0.0.0/32"
    }
}
