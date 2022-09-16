data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_vpc_network" "net" {
  name = "net"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet"
  network_id     = resource.yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = var.yandex_region
}

locals {
  instance_count = {
    stage = 1
    prod = 2
  }
  instance = {
    v1 = data.yandex_compute_image.ubuntu.id
  }
}

resource "yandex_compute_instance" "test" {
  name = "netology"
  count = local.instance_count[terraform.workspace]
  lifecycle {
    create_before_destroy = true
  }
  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

}

resource "yandex_compute_instance" "test2" {
  name = "netology2"
  for_each = local.instance
  platform_id = each.key
  lifecycle {
    create_before_destroy = true
  }
  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = each.value
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

}