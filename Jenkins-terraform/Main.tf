resource "aws_iam_role" "role1" {
  name = "Jenkins-terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.role1.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
resource "aws_iam_instance_profile" "role-profile" {
  name = "Jenkins-terraform"
  role = aws_iam_role.role1.name
}
resource "aws_security_group" "jenkins-sg" {
  name        = "Jenkins-sg"
  description = "open ports for 8080, 22, 443, 80, 9000, 3000"

  ingress {
    description = "Allow traffic on ports 22, 80, 443, 3000, 8080, and 9000"
    from_port   = 22
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = false
  }

  /* ingress = {
    description = "TLS from VPC"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    description = "TLS from VPC"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    description = "TLS from VPC"
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress = {
    description = "TLS from VPC"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    description = "TLS from VPC"
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.large"
  key_name               = "Devops"
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  user_data              = base64encode(file("../jenkins.sh"))
  iam_instance_profile   = aws_iam_instance_profile.role-profile.name

  tags = {
    Name = "Jenkins-Server"
  }
  root_block_device {
    volume_size = 30
  }
}
  
