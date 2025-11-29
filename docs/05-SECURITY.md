# Seguridad - pautas

- **No commitear** claves privadas, archivos `.tfvars` con secrets, ni paquetes generados.
- Mantener `.gitignore` actualizado.
- Para CI (GitHub Actions) usar Secrets en GitHub (Settings → Secrets).
- Para ejecución remota de Terraform usar una cuenta/role con privilegios mínimos.
