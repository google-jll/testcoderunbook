variable "project_id" {
  description = "The GCP project to create the health check in."
  type        = string
}

variable "name" {
  description = "Name of the health check."
  type        = string
}

variable "type" {
  description = "Protocol of the health check: \"http\", \"https\", or \"tcp\"."
  type        = string
  default     = "tcp"

  validation {
    condition     = contains(["http", "https", "tcp"], var.type)
    error_message = "The \"type\" variable must be one of \"http\", \"https\", or \"tcp\"."
  }
}

variable "port" {
  description = "The TCP port number for the health check request."
  type        = number
  default     = 80
}

variable "request_path" {
  description = "The request path of the HTTP(S) health check request. Ignored for tcp."
  type        = string
  default     = "/"
}

variable "host" {
  description = "The value of the host header in the HTTP(S) health check request. Ignored for tcp."
  type        = string
  default     = ""
}

variable "request" {
  description = "The application data to send once the TCP connection is established. Only used for tcp."
  type        = string
  default     = ""
}

variable "response" {
  description = "The bytes to match against the beginning of the response data."
  type        = string
  default     = ""
}

variable "proxy_header" {
  description = "The type of proxy header to append before sending data: NONE or PROXY_V1."
  type        = string
  default     = "NONE"
}

variable "check_interval_sec" {
  description = "How often (in seconds) to send a health check."
  type        = number
  default     = 5
}

variable "timeout_sec" {
  description = "How long (in seconds) to wait before claiming failure."
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Consecutive successes required to mark an instance healthy."
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Consecutive failures required to mark an instance unhealthy."
  type        = number
  default     = 2
}

variable "enable_logging" {
  description = "Whether to export health check logs to Cloud Logging."
  type        = bool
  default     = false
}
