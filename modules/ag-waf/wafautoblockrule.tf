
resource "aws_waf_rule" "WAFAutoBlockRule" {
    depends_on = ["aws_waf_ipset.WAFAutoBlockSet"]
    name = "${var.customer} - Auto Block Rule"
    metric_name = "SecurityAutomationsAutoBlockRule"
    predicates {
        data_id = "${aws_waf_ipset.WAFAutoBlockSet.id}"
        negated = false
        type = "IPMatch"
    }
}
