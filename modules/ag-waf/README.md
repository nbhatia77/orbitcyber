## AWS WAF Security Automation - modular with Terraform

This provides a modular way to deploy the WAF Reference Architecture (see bellow for image)

### Getting Started is very simple

Please make sure your creds are passed either via aws config or sts-assume-role. 



## S3 creation - Update main.tf

For each project/customer's CDN S3 bucket, run:

S3 bucket created - ` s3-ag-waf `

```

% ./waf --help
Usage: ./waf <customer> <s3-logs-bucket> <command>

<command> Options:
    create = create a new WAF setup for <customer>
    delete = delete a given <customer> WAF setup

Example: ./waf auto-grid ag-waflambdafiles create
Example: ./waf auto-grid ag-waflambdafiles delete
```


#### WAF Reference Architecture:
https://d0.awsstatic.com/aws-answers/answers-images/waf-solution-architecture.png

#### Documentation on WAF Security Automation:
http://docs.aws.amazon.com/solutions/latest/aws-waf-security-automations/architecture.html

#### Amazon WAF 4 Steps to customization:
http://docs.aws.amazon.com/solutions/latest/aws-waf-security-automations/deployment.html

#### Amazon's WAF Security Lambdas (latest via GitHub):
https://github.com/awslabs/aws-waf-security-automations
