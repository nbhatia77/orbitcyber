
resource "aws_waf_rule" "WAFIPReputationListsRule1" {
    depends_on = ["aws_waf_ipset.WAFReputationListsSet1"]
    name = "${var.customer} - WAF IP Reputation Lists Rule #1"
    metric_name = "SecurityAutomationsIPReputationListsRule1"
    predicates {
        data_id = "${aws_waf_ipset.WAFReputationListsSet1.id}"
        negated = false
        type = "IPMatch"
    }
}
