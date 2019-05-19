

## Module to buil encrypted root volume of an AMI:

1. Change variables file only with region, AMI id available to your account or from AWS Market place. 

2. Please make sure to choose 64-bit AMI with HVM support.

3. Encrypted AMI should be copied to another region to make it available in that region under the same account.

4. Once you've encrypted root vol AMI - Please destroy the environmet by doing the following:

    `terraform state list`
    `terraform state rm aws_ami_copy.ami`
    `terraform state rm aws_kms_alias.enc_key`
    `terraform state rm aws_kms_key.enc_key`
    `terraform destroy -refresh=false`