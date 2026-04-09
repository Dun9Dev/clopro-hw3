# Создание бакета Object Storage с шифрованием
resource "yandex_storage_bucket" "images" {
  bucket     = "${var.bucket_name}-${random_string.suffix.result}"
  folder_id  = var.yc_folder_id
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  anonymous_access_flags {
    read = true
    list = false
  }

  # Добавляем шифрование через KMS ключ
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

}

# Генерация случайного суффикса для уникальности имени бакета
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Создание сервисного аккаунта для доступа к Object Storage
resource "yandex_iam_service_account" "sa" {
  name = "storage-sa"
}

# Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

# Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
}

# Загрузка картинки в бакет
resource "yandex_storage_object" "image" {
  bucket     = yandex_storage_bucket.images.bucket
  key        = "sample.jpg"
  source     = "sample.jpg"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}

# Добавление ролей для работы с сетью и ВМ
resource "yandex_resourcemanager_folder_iam_member" "sa-network-user" {
  folder_id = var.yc_folder_id
  role      = "vpc.user"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-compute-admin" {
  folder_id = var.yc_folder_id
  role      = "compute.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-iam-admin" {
  folder_id = var.yc_folder_id
  role      = "iam.serviceAccounts.user"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor-full" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

# Вывод URL картинки
output "image_url" {
  description = "URL of the uploaded image"
  value       = "https://${yandex_storage_bucket.images.bucket}.storage.yandexcloud.net/${yandex_storage_object.image.key}"
}
