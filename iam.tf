#--------------------------------------------------------------
# Bastion Instance Profile
#--------------------------------------------------------------
resource "aws_iam_instance_profile" "bastion_profile" {
  name  = "bastion-profile-${var.bastion_environment}"
  roles = ["${aws_iam_role.bastion_role.name}"]

  # For details, see https://github.com/hashicorp/terraform/issues/5862.
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

#--------------------------------------------------------------
# Bastion IAM Role
#--------------------------------------------------------------
resource "aws_iam_role" "bastion_role" {
  name = "bastion-role-${var.bastion_environment}"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
        },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
