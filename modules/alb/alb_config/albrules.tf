
resource "aws_wafregional_byte_match_set" "bot-user-agent" {
  name = "${var.customer} - MatchBotInUserAgent"
  byte_match_tuples {
    text_transformation = "LOWERCASE"
    target_string = "bot"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "HEADER"
      data = "user-agent"
    }
  }
}

resource "aws_wafregional_byte_match_set" "match-uri" {
  name = "${var.customer} - MatchRouteInURI"
  byte_match_tuples {
    text_transformation = "NONE"
    target_string = "route"
    positional_constraint = "CONTAINS"
    field_to_match {
      type = "URI"
    }
  }
}

resource "aws_wafregional_rule" "bot-route-control-rule" {
  name        = "${var.customer} - MatchBotsAndRoute"
  metric_name = "MatchBotsAndRoute"

  predicate {
    data_id = "${aws_wafregional_byte_match_set.bot-user-agent.id}"
    negated = false
    type    = "ByteMatch"
  }
  predicate {
    data_id = "${aws_wafregional_byte_match_set.match-uri.id}"
    negated = false
    type    = "ByteMatch"
  }
}

resource "aws_wafregional_ipset" "WAFBadBotSet" {
  name = "${var.customer} - IP Bad Bot Set"
  ip_set_descriptor {
    type = "IPV4"
    value = "0.0.0.0/32"
  }
}

resource "aws_wafregional_rule" "WAFBadBotRule" {
  depends_on = ["aws_wafregional_ipset.WAFBadBotSet"]
  name = "${var.customer} - Bad Bot Rule"
  metric_name = "SecurityAutomationsBadBotRule"
  predicate {
    data_id = "${aws_wafregional_ipset.WAFBadBotSet.id}"
    negated = false
    type = "IPMatch"
  }
}

resource "aws_wafregional_ipset" "WAFAutoBlockSet" {
  name = "${var.customer} - Auto Block Set"
  ip_set_descriptor {
    type = "IPV4"
    value = "0.0.0.0/32"
  }
}

resource "aws_wafregional_rule" "WAFAutoBlockRule" {
  depends_on = ["aws_wafregional_ipset.WAFAutoBlockSet"]
  name = "${var.customer} - Auto Block Rule"
  metric_name = "SecurityAutomationsAutoBlockRule"
  predicate {
    data_id = "${aws_wafregional_ipset.WAFAutoBlockSet.id}"
    negated = false
    type = "IPMatch"
  }
}

resource "aws_wafregional_ipset" "WAFBlacklistSet" {
  name = "${var.customer} - Blacklist Set"
  ip_set_descriptor {
    type = "IPV4"
    value = "0.0.0.0/32"
  }
}

resource "aws_wafregional_rule" "WAFBlacklistRule" {
  depends_on = ["aws_wafregional_ipset.WAFBlacklistSet"]
  name = "${var.customer} - Blacklist Rule"
  metric_name = "SecurityAutomationsBlacklistRule"
  predicate {
    data_id = "${aws_wafregional_ipset.WAFBlacklistSet.id}"
    negated = false
    type = "IPMatch"
  }
}

resource "aws_wafregional_xss_match_set" "WAFXssDetection" {
  name = "${var.customer} - XSS Detection Detection"
  xss_match_tuple {
    text_transformation = "URL_DECODE"
    field_to_match {
      type = "QUERY_STRING"
      data = "none"
    }
  }
  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"
    field_to_match {
      type = "QUERY_STRING"
      data = "none"
    }
  }
  xss_match_tuple {
    text_transformation = "URL_DECODE"
    field_to_match {
      type = "BODY"
      data = "none"
    }
  }
  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"
    field_to_match {
      type = "BODY"
      data = "none"
    }
  }
  xss_match_tuple {
    text_transformation = "URL_DECODE"
    field_to_match {
      type = "URI"
      data = "none"
    }
  }
  xss_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"
    field_to_match {
      type = "URI"
      data = "none"
    }
  }
}

resource "aws_wafregional_rule" "WAFXssRule" {
  depends_on = ["aws_wafregional_xss_match_set.WAFXssDetection"]
  name = "${var.customer} - XSS Rule"
  metric_name = "SecurityAutomationsXssRule"
  predicate {
    data_id = "${aws_wafregional_xss_match_set.WAFXssDetection.id}"
    negated = false
    type = "XssMatch"
  }
}

resource "aws_wafregional_ipset" "WAFReputationListsSet1" {
  name = "${var.customer} - IP Reputation Lists Set #1"
  ip_set_descriptor {
    type = "IPV4"
    value = "0.0.0.0/32"
  }    
  lifecycle {
    ignore_changes = ["ip_set_descriptors"]
  }
}

resource "aws_wafregional_rule" "WAFIPReputationListsRule1" {
  depends_on = ["aws_wafregional_ipset.WAFReputationListsSet1"]
  name = "${var.customer} - WAF IP Reputation Lists Rule #1"
  metric_name = "SecurityAutomationsIPReputationListsRule1"
  predicate {
    data_id = "${aws_wafregional_ipset.WAFReputationListsSet1.id}"
    negated = false
    type = "IPMatch"
  }
}

resource "aws_wafregional_ipset" "WAFReputationListsSet2" {
  name = "${var.customer} - IP Reputation Lists Set #2"
  ip_set_descriptor {
    type = "IPV4"
    value = "0.0.0.0/32"
  }    
  lifecycle {
    ignore_changes = ["ip_set_descriptors"]
  }
}

resource "aws_wafregional_rule" "WAFIPReputationListsRule2" {
  depends_on = ["aws_wafregional_ipset.WAFReputationListsSet2"]
  name = "${var.customer} - WAF IP Reputation Lists Rule #2"
  metric_name = "SecurityAutomationsIPReputationListsRule2"
  predicate {
    data_id = "${aws_wafregional_ipset.WAFReputationListsSet2.id}"
    negated = false
    type = "IPMatch"
  }
}

resource "aws_wafregional_sql_injection_match_set" "WAFSqlInjectionDetection" {
  name = "${var.customer} - SQL Injection Detection"

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"
    field_to_match {
      type = "QUERY_STRING"
      data = "none"
    }
  }
  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"
    field_to_match {
      type = "QUERY_STRING"
      data = "none"
    }
  }
  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"
    field_to_match {
      type = "BODY"
      data = "none"
    }
  }
  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"
    field_to_match {
      type = "BODY"
      data = "none"
    }
  }
  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"
    field_to_match {
      type = "URI"
      data = "none"
    }
  }
  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"
    field_to_match {
      type = "URI"
      data = "none"
    }
  }
}

resource "aws_wafregional_rule" "WAFSqlInjectionRule" {
  depends_on = ["aws_wafregional_sql_injection_match_set.WAFSqlInjectionDetection"]
  name = "${var.customer} - SQL Injection Rule"
  metric_name = "SecurityAutomationsSqlInjectionRule"
  predicate {
    data_id = "${aws_wafregional_sql_injection_match_set.WAFSqlInjectionDetection.id}"
    negated = false
    type = "SqlInjectionMatch"
  }
}

resource "aws_wafregional_ipset" "WAFWhitelistSet" {
  name = "${var.customer} - Whitelist Set"
  ip_set_descriptor {
    type = "IPV4"
    value = "0.0.0.0/32"
  }
}

resource "aws_wafregional_rule" "WAFWhitelistRule" {
  depends_on = ["aws_wafregional_ipset.WAFBlacklistSet"]
  name = "${var.customer} - Whitelist Rule"
  metric_name = "SecurityAutomationsWhitelistRule"
  predicate {
    data_id = "${aws_wafregional_ipset.WAFWhitelistSet.id}"
    negated = false
    type = "IPMatch"
  }
}
