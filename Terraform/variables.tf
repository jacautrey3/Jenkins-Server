variable "aws_region" {
  default = "us-west-1"
  type    = string
}

variable "ami_id" {
  default = "ami-07619059e86eaaaa2"
  type    = string
}

variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "key_name" {
  default = "jenkins_key"
  type    = string
}

variable "vpc_id" {
  default = "vpc-0063ef0d505b1e399"
  type    = string
}

variable "sg_name" {
  default = "jenkins_sg"
  type    = string
}

variable "bucket" {
  default = "jenkins-s3-bucket-jautrey"
  type    = string
}

variable "acl" {
  default = "private"
  type    = string
}

variable "private_key_path" {
  type = string
}
