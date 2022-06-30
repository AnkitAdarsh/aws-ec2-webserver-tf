
resource "aws_instance" "ankit-webserver" {
  ami               = var.ami_id
  key_name          = var.key_name
  instance_type     = var.instance_type
  security_groups   = [var.security_group]
  iam_instance_profile = "${aws_iam_instance_profile.cw_profile.name}"
  user_data = file("startWebServer.sh")

  tags = {
    Name = var.tag_name
  }
}

# Create Elastic IP address
resource "aws_eip" "ankit-webserver" {
  vpc      = true
  instance = aws_instance.ankit-webserver.id
tags= {
    Name = "my_elastic_ip"
  }
}

resource "aws_iam_role" "ec2_cw_access_role" {
    name               = "cw-role"
    assume_role_policy = "${file("assumerolepolicy.json")}"
}

resource "aws_iam_policy" "cw_policy" {
  name        = "cw_policy"
  description = "A test policy"
  policy      = "${file("policycloudwatch.json")}"
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.ec2_cw_access_role.name}"]
  policy_arn = "${aws_iam_policy.cw_policy.arn}"
}

resource "aws_iam_instance_profile" "cw_profile" {                             
    name  = "cw_profile"                         
    role  = "${aws_iam_role.ec2_cw_access_role.name}"
}
