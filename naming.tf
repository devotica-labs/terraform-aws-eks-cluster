# Native resource naming + tagging.
#
# Composes an id from namespace / environment / stage / name joined by a
# delimiter, and a base tag set merged with the caller's tags. The cluster id
# additionally appends `cluster_attributes` (default ["cluster"]).

variable "enabled" {
  type        = bool
  description = "Set to false to make this module a no-op (create nothing)."
  default     = true
}

variable "namespace" {
  type        = string
  description = "Namespace / org prefix used to compose resource names (e.g. \"dvtca\")."
  default     = null
}

variable "environment" {
  type        = string
  description = "Environment segment used to compose resource names (e.g. a short region code)."
  default     = null
}

variable "stage" {
  type        = string
  description = "Stage / account segment used to compose resource names (e.g. \"prod\")."
  default     = null
}

variable "name" {
  type        = string
  description = "Base name used to compose resource names (e.g. \"payments\")."
  default     = null
}

variable "delimiter" {
  type        = string
  description = "Delimiter joining the resource-name segments."
  default     = "-"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every taggable resource this module creates."
  default     = {}
}

locals {
  # Ordered name segments: namespace - environment - stage - name [- attributes]
  name_segments = [var.namespace, var.environment, var.stage, var.name]

  id_base = join(var.delimiter, compact(local.name_segments))
  id      = join(var.delimiter, compact(concat(local.name_segments, var.cluster_attributes)))

  # Identity tags generated from the set name segments, merged under the
  # caller's tags (caller tags win on conflict).
  _identity_tags = {
    Name        = local.id
    Namespace   = var.namespace
    Environment = var.environment
    Stage       = var.stage
  }
  tags      = merge({ for k, v in local._identity_tags : k => v if v != null && v != "" }, var.tags)
  base_tags = local.tags

  # Capability resource names: <id_base>-capability-<key>
  capability_ids = {
    for k in local.enabled_capability_keys : k =>
    join(var.delimiter, compact(concat(local.name_segments, ["capability", k])))
  }
}
