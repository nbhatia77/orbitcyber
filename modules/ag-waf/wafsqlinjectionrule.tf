
resource "aws_waf_rule" "WAFSqlInjectionRule" {
    depends_on = ["aws_waf_sql_injection_match_set.WAFSqlInjectionDetection"]
    name = "${var.customer} - SQL Injection Rule"
    metric_name = "SecurityAutomationsSqlInjectionRule"
    predicates {
        data_id = "${aws_waf_sql_injection_match_set.WAFSqlInjectionDetection.id}"
        negated = false
        type = "SqlInjectionMatch"
      }
}
