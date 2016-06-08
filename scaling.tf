#---------------------------------------------------------------
# Bastion Autoscaling Group
#---------------------------------------------------------------
resource "aws_autoscaling_group" "bastion_asg" {
  name                      = "${var.bastion_asg_name}-${var.bastion_environment}"
  vpc_zone_identifier       = ["${split(",", var.bastion_asg_subnets)}"]
  launch_configuration      = "${aws_launch_configuration.bastion_lc.id}"
  max_size                  = 1
  min_size                  = 1
  wait_for_elb_capacity     = 1
  health_check_type         = "ELB"
  load_balancers            = ["${aws_elb.bastion_elb.name}"]
  health_check_grace_period = "${var.bastion_asg_grace_period}"

  tag {
    key                 = "role"
    value               = "bastion"
    propagate_at_launch = true
  }
}

#---------------------------------------------------------------
# Bastion Autoscaling Launch Configuration
#---------------------------------------------------------------
resource "aws_launch_configuration" "bastion_lc" {
  name_prefix          = "bastion-lc-${var.bastion_environment}"
  image_id             = "${lookup(var.bastion_ami, var.global_region)}"
  instance_type        = "${var.bastion_instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.bastion_profile.id}"
  key_name             = "${var.bastion_keypair}"
  security_groups      = ["${aws_security_group.bastion_sg.id}"]
  user_data            = "${template_file.init.rendered}"
}
