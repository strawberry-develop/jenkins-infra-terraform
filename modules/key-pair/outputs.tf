output "key_name" {
  description = "키 페어 이름"
  value       = aws_key_pair.main.key_name
}

output "key_pair_id" {
  description = "키 페어 ID"
  value       = aws_key_pair.main.key_pair_id
}

output "fingerprint" {
  description = "키 페어 지문"
  value       = aws_key_pair.main.fingerprint
} 