# Создание сетевого балансировщика
resource "yandex_lb_network_load_balancer" "lamp-balancer" {
  name = "lamp-load-balancer"

  listener {
    name = "http-listener"
    port = 80
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp-group.load_balancer[0].target_group_id

    healthcheck {
      name = "http-health-check"
      interval = 2
      timeout = 1
      unhealthy_threshold = 2
      healthy_threshold = 2

      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

# Вывод информации о балансировщике
output "balancer_name" {
  description = "Name of the load balancer"
  value       = yandex_lb_network_load_balancer.lamp-balancer.name
}
