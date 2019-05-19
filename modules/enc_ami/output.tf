output "enc_image_id" {
    value = "${aws_ami_copy.ami.id}"
}

output "enc_enhanced_net" {
  value = "${aws_ami_from_instance.ami.sriov_net_support}"
}

output "enc_ami_virtualization_type" {
  value = "${aws_ami_from_instance.ami.virtualization_type}"
}

