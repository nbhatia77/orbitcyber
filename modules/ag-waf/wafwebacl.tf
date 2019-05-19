
resource "aws_waf_web_acl" "WAFWebACL" {
    depends_on = ["aws_waf_rule.WAFWhitelistRule", "aws_waf_rule.WAFBlacklistRule", "aws_waf_rule.WAFAutoBlockRule", "aws_waf_rule.WAFIPReputationListsRule1", "aws_waf_rule.WAFIPReputationListsRule2", "aws_waf_rule.WAFBadBotRule", "aws_waf_rule.WAFSqlInjectionRule", "aws_waf_rule.WAFXssRule"]
    name = "${var.customer}"
    metric_name = "SecurityAutomationsMaliciousRequesters"
    default_action {
        type = "ALLOW"
    }
    rules {
        action {
            type = "ALLOW"
        }
        priority = 10
        rule_id = "${aws_waf_rule.WAFWhitelistRule.id}"
    }
    rules {
        action {
            type = "BLOCK"
        }
        priority = 20
        rule_id = "${aws_waf_rule.WAFBlacklistRule.id}"
    }
    rules {
        action {
            type = "BLOCK"
        }
        priority = 30
        rule_id = "${aws_waf_rule.WAFAutoBlockRule.id}"
    }
    rules {
        action {
            type = "BLOCK"
        }
        priority = 40
        rule_id = "${aws_waf_rule.WAFIPReputationListsRule1.id}"
    }
    rules {
        action {
            type = "BLOCK"
        }
        priority = 50
        rule_id = "${aws_waf_rule.WAFIPReputationListsRule2.id}"
    }
    rules {
        action {
            type = "BLOCK"
        }
        priority = 60
        rule_id = "${aws_waf_rule.WAFBadBotRule.id}"
    }
    rules {
        action {
            type = "BLOCK"
        }
        priority = 70
        rule_id = "${aws_waf_rule.WAFSqlInjectionRule.id}"
    }
    rules {
        action {
            type = "BLOCK"
        }
        priority = 80
        rule_id = "${aws_waf_rule.WAFXssRule.id}"
    }
}
