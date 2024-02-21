locals {
  private_key_path = "~/projects/jenkins_key.pem"
}
#Create EC2 Instance
resource "aws_instance" "jenkins-ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  tags = {
    Name    = "Jenkins"
    Project = "Jenkins"
  }
}

resource "null_resource" "ansible" {
  depends_on = [aws_instance.jenkins-ec2]
  # Provisioning for Ansible
  provisioner "remote-exec" {
    inline = ["echo 'Wati until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(local.private_key_path)
      host        = aws_instance.jenkins-ec2.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.jenkins-ec2.public_ip}, --private-key ${local.private_key_path} ~/projects/Jenkins-Server/Ansible/jenkins.yaml"
  }
}

#Create security group 
resource "aws_security_group" "jenkins-sg" {
  name        = var.sg_name
  description = "Allow inbound ports 22, 8080"
  vpc_id      = var.vpc_id

  #Allow incoming TCP requests on port 22 from any IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Allow incoming TCP requests on port 443 from any IP
  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow incoming TCP requests on port 8080 from any IP
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create S3 bucket for Jenksin Artifacts
resource "aws_s3_bucket" "my-s3-bucket" {
  bucket = var.bucket

  tags = {
    Name    = "Jenkins"
    Project = "Jenkins"
  }
}

#make sure is prive and not open to public and create Access control List
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket     = aws_s3_bucket.my-s3-bucket.id
  acl        = var.acl
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.my-s3-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_iam_role" "s3-jenkins-role" {
  name                  = "s3-jenkins_role"
  force_detach_policies = true
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" #service level Access
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "Jenkins"
  }
}

resource "aws_iam_policy" "s3-jenkins-policy" {
  name = "s3-jenkins-rw-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "S3ReadWriteAccess",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.my-s3-bucket.arn,
          "${aws_s3_bucket.my-s3-bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3-jenkins-access" {
  policy_arn = aws_iam_policy.s3-jenkins-policy.arn
  role       = aws_iam_role.s3-jenkins-role.name
}

resource "aws_iam_instance_profile" "s3-jenkins-profile" {
  name = "s3-jenkins-profile"
  role = aws_iam_role.s3-jenkins-role.name
}
