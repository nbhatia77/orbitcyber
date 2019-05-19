
resource "aws_waf_xss_match_set" "WAFXssDetection" {
    name = "${var.customer} - XSS Detection Detection"
    xss_match_tuples {
        text_transformation = "URL_DECODE"
        field_to_match {
            type = "QUERY_STRING"
            data = "none"
        }
    }
    xss_match_tuples {
        text_transformation = "HTML_ENTITY_DECODE"
        field_to_match {
            type = "QUERY_STRING"
            data = "none"
        }
    }
    xss_match_tuples {
        text_transformation = "URL_DECODE"
        field_to_match {
            type = "BODY"
            data = "none"
        }
    }
    xss_match_tuples {
        text_transformation = "HTML_ENTITY_DECODE"
        field_to_match {
            type = "BODY"
            data = "none"
        }
    }
    xss_match_tuples {
        text_transformation = "URL_DECODE"
        field_to_match {
            type = "URI"
            data = "none"
        }
    }
    xss_match_tuples {
        text_transformation = "HTML_ENTITY_DECODE"
        field_to_match {
            type = "URI"
            data = "none"
        }
    }
}
