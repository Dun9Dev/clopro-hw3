# Создание симметричного ключа в KMS
resource "yandex_kms_symmetric_key" "bucket-key" {
  name              = "bucket-encryption-key"
  description       = "Key for bucket encryption"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" # 1 год
}

# Вывод ID ключа
output "kms_key_id" {
  description = "ID of the KMS key"
  value       = yandex_kms_symmetric_key.bucket-key.id
}
