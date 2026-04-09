# Получение ID подсети public из предыдущей инфраструктуры
data "yandex_vpc_subnet" "public" {
  name = "public"
}

# Получение ID сети
data "yandex_vpc_network" "main" {
  name = "main-vpc"
}

# Шаблон для создания ВМ
resource "yandex_compute_instance_group" "lamp-group" {
  name                = "lamp-instance-group"
  folder_id           = var.yc_folder_id
  service_account_id  = yandex_iam_service_account.sa.id
  deletion_protection = false

  instance_template {
    platform_id = "standard-v3"
    resources {
      cores  = 2
      memory = 2
    }

    boot_disk {
      initialize_params {
        image_id = var.lamp_image_id
        size     = 10
      }
    }

    network_interface {
      network_id = data.yandex_vpc_network.main.id
      subnet_ids = [data.yandex_vpc_subnet.public.id]
      nat        = true
    }

    metadata = {
      user-data = <<-EOF
        #!/bin/bash
        echo '<html><body><h1>LAMP Server</h1><p>Instance: '$(hostname)'</p><img src="https://${yandex_storage_bucket.images.bucket}.storage.yandexcloud.net/${yandex_storage_object.image.key}" alt="Yandex Logo"></body></html>' > /var/www/html/index.html
        systemctl restart apache2
        EOF
    }

    network_settings {
      type = "STANDARD"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  health_check {
    interval = 30
    timeout  = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3

    http_options {
      port = 80
      path = "/"
    }
  }

  load_balancer {
    target_group_name = "lamp-target-group"
  }
}

# Вывод IP адресов ВМ
output "instance_group_ips" {
  description = "Public IPs of instances in the group"
  value       = yandex_compute_instance_group.lamp-group.instances[*].network_interface[0].nat_ip_address
}
