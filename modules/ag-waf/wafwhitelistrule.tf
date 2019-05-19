
resource "aws_waf_rule" "WAFWhitelistRule" {
    depends_on = ["aws_waf_ipset.WAFWhitelistSet"]
    name = "${var.customer} - Whitelist Rule"
    metric_name = "SecurityAutomationsWhitelistRule"
    predicates {
        data_id = "${aws_waf_ipset.WAFWhitelistSet.id}"
        negated = false
        type = "IPMatch"
    }
}
