
resource "aws_waf_rule" "WAFBadBotRule" {
    depends_on = ["aws_waf_ipset.WAFBadBotSet"]
    name = "${var.customer} - Bad Bot Rule"
    metric_name = "SecurityAutomationsBadBotRule"
    predicates {
        data_id = "${aws_waf_ipset.WAFBadBotSet.id}"
        negated = false
        type = "IPMatch"
    }
}
