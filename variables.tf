variable "region" {
  default = "us-east-1"
}

variable "aws_profile" {
  default = "torus"
}

variable "timeZone" {
  default= "America/Lima"
}

variable "startHour" {
  description = "make the coverntion to UTC hour"
  default = "13"
  # in lima would be 8
}

variable "stopHour" {
  description = "make the coverntion to UTC hour"
  default = "4"
  # in lima would be 23 
}

