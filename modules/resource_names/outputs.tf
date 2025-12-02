output "resource_names" {
  description = "Map of fully resolved resource names with all template variables substituted. Contains actual resource names to be used for creating Azure resources, repositories, pipelines, and other infrastructure components. Includes both base values and computed values (e.g., location abbreviations, incremented numbers, random strings for globally unique names)."
  value       = local.resource_names
}
