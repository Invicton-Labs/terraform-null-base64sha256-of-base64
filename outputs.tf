output "base64" {
  description = "The base64-encoded SHA256 hash of the decoded base64 content."
  value       = local.base64
}

output "hex" {
  description = "The hex-encoded SHA256 hash of the decoded base64 content. Will always use lower-case letters."
  value       = local.hex
}
