
resource "aws_s3_bucket" "WAFLambdaFiles" {
    bucket = "${var.customer}-waflambdafiles"
    acl = "private"

    tags {
        Name = "WAF Lambda Files"
        Environment = "Production"
    }
}
resource "aws_s3_bucket_object" "LogParserZip" {
    depends_on = ["aws_s3_bucket.WAFLambdaFiles"]
    bucket = "${var.customer}-waflambdafiles"
    key = "log-parser.zip"
    source = "files/log-parser/log-parser.zip"
    etag = "${md5(file("files/log-parser/log-parser.zip"))}"
}
resource "aws_s3_bucket_object" "CustomResourceZip" {
    depends_on = ["aws_s3_bucket.WAFLambdaFiles"]
    bucket = "${var.customer}-waflambdafiles"
    key = "custom-resource.zip"
    source = "files/custom-resource/custom-resource.zip"
    etag = "${md5(file("files/custom-resource/custom-resource.zip"))}"
}
resource "aws_s3_bucket_object" "AccessHandlerZip" {
    depends_on = ["aws_s3_bucket.WAFLambdaFiles"]
    bucket = "${var.customer}-waflambdafiles"
    key = "access-handler.zip"
    source = "files/access-handler/access-handler.zip"
    etag = "${md5(file("files/access-handler/access-handler.zip"))}"
}
resource "aws_s3_bucket_object" "ReputationListsParserZip" {
    depends_on = ["aws_s3_bucket.WAFLambdaFiles"]
    bucket = "${var.customer}-waflambdafiles"
    key = "reputation-lists-parser.zip"
    source = "files/reputation-lists-parser/reputation-lists-parser.zip"
    etag = "${md5(file("files/reputation-lists-parser/reputation-lists-parser.zip"))}"
}
resource "aws_s3_bucket_object" "SolutionHelperZip" {
    depends_on = ["aws_s3_bucket.WAFLambdaFiles"]
    bucket = "${var.customer}-waflambdafiles"
    key = "solution-helper.zip"
    source = "files/solution-helper/solution-helper.zip"
    etag = "${md5(file("files/solution-helper/solution-helper.zip"))}"
}
