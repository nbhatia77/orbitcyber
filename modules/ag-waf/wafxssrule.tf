
resource "aws_waf_rule" "WAFXssRule" {
    depends_on = ["aws_waf_xss_match_set.WAFXssDetection"]
    name = "${var.customer} - XSS Rule"
    metric_name = "SecurityAutomationsXssRule"
    predicates {
        data_id = "${aws_waf_xss_match_set.WAFXssDetection.id}"
        negated = false
        type = "XssMatch"
    }
}
