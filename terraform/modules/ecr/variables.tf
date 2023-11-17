variable "create" {
    description = "Determines whether resources will be created (affects all resources)"
    type        = bool
    default     = true
}

variable "tags" {
    description = "A map of tags to add to all resources"
    type        = map(string)
    default     = {}
}

variable "repository_type" {
    description = "The type of repository to create. Either `public` or `private`"
    type        = string
    default     = "private"
}

variable "create_repository" {
    description = "Determines whether a repository will be created"
    type        = bool
    default     = true
}

variable "repository_name" {}

variable "repository_image_tag_mutability" {
    description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`. Defaults to `IMMUTABLE`"
    type        = string
    default     = "MUTABLE"
}

variable "repository_image_scan_on_push" {
    description = "Indicates whether images are scanned after being pushed to the repository (`true`) or not scanned (`false`)"
    type        = bool
    default     = true
}