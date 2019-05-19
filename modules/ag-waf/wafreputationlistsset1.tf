
resource "aws_waf_ipset" "WAFReputationListsSet1" {
    name = "${var.customer} - IP Reputation Lists Set #1"
    ip_set_descriptors {
        type = "IPV4"
        value = "0.0.0.0/32"
    }    
    lifecycle {
        ignore_changes = ["ip_set_descriptors"]
    }
}
