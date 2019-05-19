resource "aws_wafregional_web_acl" "ALBWAFWebACL" {
    depends_on = ["aws_wafregional_rule.WAFWhitelistRule", "aws_wafregional_rule.WAFBlacklistRule", "aws_wafregional_rule.WAFAutoBlockRule", "aws_wafregional_rule.WAFIPReputationListsRule1", "aws_wafregional_rule.WAFIPReputationListsRule2", "aws_wafregional_rule.WAFBadBotRule", "aws_wafregional_rule.WAFSqlInjectionRule", "aws_wafregional_rule.WAFXssRule", "aws_wafregional_rule.bot-route-control-rule"]
    name = "${var.customer} - Applied ALB WAF ACLs"
    metric_name = "SecurityAutomationsMaliciousRequesters"
    default_action {
        type = "ALLOW"
    }
    rule {
        action {
            type = "ALLOW"
        }
        priority = 10
        rule_id = "${aws_wafregional_rule.WAFWhitelistRule.id}"
    }
    rule {
        action {
            type = "BLOCK"
        }
        priority = 20
        rule_id = "${aws_wafregional_rule.WAFBlacklistRule.id}"
    }
    rule {
        action {
            type = "BLOCK"
        }
        priority = 30
        rule_id = "${aws_wafregional_rule.WAFAutoBlockRule.id}"
    }
    rule {
        action {
            type = "BLOCK"
        }
        priority = 40
        rule_id = "${aws_wafregional_rule.WAFIPReputationListsRule1.id}"
    }
    rule {
        action {
            type = "BLOCK"
        }
        priority = 50
        rule_id = "${aws_wafregional_rule.WAFIPReputationListsRule2.id}"
    }
    rule {
        action {
            type = "BLOCK"
        }
        priority = 60
        rule_id = "${aws_wafregional_rule.WAFBadBotRule.id}"
    }
    rule {
        action {
            type = "BLOCK"
        }
        priority = 70
        rule_id = "${aws_wafregional_rule.WAFSqlInjectionRule.id}"
    }
    rule {
        action {
            type = "BLOCK"
        }
        priority = 80
        rule_id = "${aws_wafregional_rule.WAFXssRule.id}"
    }
    rule {
        action {
            type = "BLOCK"
        }   
        priority = 90
        rule_id = "${aws_wafregional_rule.bot-route-control-rule.id}"
    }
}
