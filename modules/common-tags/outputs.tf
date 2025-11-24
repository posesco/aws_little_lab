# ============================================
# modules/common-tags/outputs.tf
# ============================================
output "tags" {
  description = "Mapa de tags comunes"
  value       = local.common_tags
}

