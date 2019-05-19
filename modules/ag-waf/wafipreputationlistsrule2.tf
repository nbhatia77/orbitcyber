
resource "aws_waf_rule" "WAFIPReputationListsRule2" {
    depends_on = ["aws_waf_ipset.WAFReputationListsSet2"]
    name = "${var.customer} - WAF IP Reputation Lists Rule #2"
    metric_name = "SecurityAutomationsIPReputationListsRule2"
    predicates {
        data_id = "${aws_waf_ipset.WAFReputationListsSet2.id}"
        negated = false
        type = "IPMatch"
    }
}
