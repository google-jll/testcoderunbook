variable "project_id" {
  description = "The ID of the project in which to provision Cloud KMS resources."
  type        = string
}

variable "location" {
  description = "The location for the KeyRing (e.g. 'global', 'us-central1', 'europe-west1')."
  type        = string
}

variable "keyring" {
  description = "The short name of the Cloud KMS Key Ring."
  type        = string
}

variable "labels" {
  description = "Global labels to attach to all crypto keys created by this module."
  type        = map(string)
  default     = {}
}

variable "key_names" {
  description = "List of simple symmetric crypto key names to create with default symmetric encryption and rotation."
  type        = list(string)
  default     = []
}

variable "keys" {
  description = "Map of crypto keys to create with granular settings (purpose, rotation_period, destroy_scheduled_duration, labels, version_template)."
  type = map(object({
    purpose                     = optional(string, "ENCRYPT_DECRYPT")
    rotation_period             = optional(string, "7776000s")
    destroy_scheduled_duration  = optional(string, "86400s")
    import_only                 = optional(bool, false)
    labels                      = optional(map(string), {})
    skip_initial_version_creation = optional(bool, false)
    crypto_key_backend          = optional(string, null)
    version_template = optional(object({
      algorithm        = string
      protection_level = optional(string, "SOFTWARE")
    }), null)
  }))
  default = {}
}

variable "key_iam_members" {
  description = "Map of crypto key names to a map of IAM roles and list of members to bind additively."
  type        = map(map(list(string)))
  default     = {}
}

variable "key_ring_iam_members" {
  description = "Map of IAM roles to list of members to bind additively at the KeyRing level."
  type        = map(list(string))
  default     = {}
}

variable "encrypters_decrypters" {
  description = "Map of crypto key names to list of IAM members granted roles/cloudkms.cryptoKeyEncrypterDecrypter."
  type        = map(list(string))
  default     = {}
}

variable "encrypters" {
  description = "Map of crypto key names to list of IAM members granted roles/cloudkms.cryptoKeyEncrypter."
  type        = map(list(string))
  default     = {}
}

variable "decrypters" {
  description = "Map of crypto key names to list of IAM members granted roles/cloudkms.cryptoKeyDecrypter."
  type        = map(list(string))
  default     = {}
}

variable "viewers" {
  description = "Map of crypto key names to list of IAM members granted roles/cloudkms.viewer."
  type        = map(list(string))
  default     = {}
}

variable "admins" {
  description = "Map of crypto key names to list of IAM members granted roles/cloudkms.admin."
  type        = map(list(string))
  default     = {}
}
