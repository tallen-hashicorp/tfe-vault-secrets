variable "tfe_token" {
  description = "Your TFE API Token"
  type        = string
}

variable "tfe_organization" {
  description = "value of your organization"
  type        = string
}

variable "vault_addr" {
  description = "value of your Vault address"
  type        = string
}

variable "aws_access_key_id"{
  description = "AWS Access Key ID"
  type        = string
}

variable "aws_secret_access_key"{
  description = "AWS Secret Access Key"
  type        = string
}

variable "aws_region"{
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}