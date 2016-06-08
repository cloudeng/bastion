#--------------------------------------------------------------
# Bastion ELB Security Group
#--------------------------------------------------------------
resource "aws_security_group" "bastion_elb_sg" {
  name        = "bastion-elb-sg-${var.bastion_environment}"
  description = "Authorize SSH access to the bastion ELB from trusted source networks."
  vpc_id      = "${var.global_vpc_id}"
}

resource "aws_security_group_rule" "allow_ingress_ssh_trusted" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.bastion_elb_sg.id}"
  cidr_blocks       = ["${split(",", var.bastion_trusted_networks)}"]
}

resource "aws_security_group_rule" "allow_egress_ssh_elb" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion_sg.id}"
  security_group_id        = "${aws_security_group.bastion_elb_sg.id}"
}

#-------------------------------------------------------------
# Bastion Host Security Group
#-------------------------------------------------------------
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg-${var.bastion_environment}"
  description = "Authorize SSH access to bastion host from the bastion ELB."
  vpc_id      = "${var.global_vpc_id}"
}

resource "aws_security_group_rule" "allow_ingress_ssh_elb" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.bastion_sg.id}"
  source_security_group_id = "${aws_security_group.bastion_elb_sg.id}"
}

resource "aws_security_group_rule" "allow_egress_all_bastion" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = "${aws_security_group.bastion_sg.id}"
  cidr_blocks       = ["${var.global_vpc_subnet}"]
}

#-------------------------------------------------------------
# Bastion Source Security Group
#-------------------------------------------------------------
resource "aws_security_group" "bastion_source_sg" {
  name        = "bastion-source-sg-${var.bastion_environment}"
  description = "Authorize SSH access from the bastion host."
  vpc_id      = "${var.global_vpc_id}"
}

resource "aws_security_group_rule" "allow_ingress_ssh_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion_sg.id}"
  security_group_id        = "${aws_security_group.bastion_source_sg.id}"
}
