
resource "aws_waf_ipset" "WAFReputationListsSet2" {
    name = "${var.customer} - IP Reputation Lists Set #2"
    ip_set_descriptors {
        type = "IPV4"
        value = "0.0.0.0/32"
    }    
    lifecycle {
        ignore_changes = ["ip_set_descriptors"]
    }
}
