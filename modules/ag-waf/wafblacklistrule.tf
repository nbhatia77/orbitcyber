
resource "aws_waf_rule" "WAFBlacklistRule" {
    depends_on = ["aws_waf_ipset.WAFBlacklistSet"]
    name = "${var.customer} - Blacklist Rule"
    metric_name = "SecurityAutomationsBlacklistRule"
    predicates {
        data_id = "${aws_waf_ipset.WAFBlacklistSet.id}"
        negated = false
        type = "IPMatch"
    }
}
