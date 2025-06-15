terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "image-13ft" {
  name = "ghcr.io/wasi-master/13ft:latest"
}

resource "docker_container" "container-13ft" {
  image = docker_image.image-13ft.image_id
  name  = "container-13ft"
  ports {
    internal = 5000
    external = 5000
  }
}

resource "docker_image" "image-pihole" {
  name = "pihole/pihole:latest"
}


resource "docker_container" "container-pihole" {
  image = docker_image.image-pihole.image_id
  name  = "container-pihole"
  env = ["TZ='America/New York"]
  must_run = true

  capabilities {
    add = ["NET_ADMIN"]
  }

  volumes {

  host_path = "/opt/containers/pihole/etc-pihole/"
  container_path = "/etc/pihole"
  }

  ports {
    protocol = "tcp udp"
    internal = "53"
    external = "53"
    }
  ports {
    protocol = "tcp"
    internal = "80"
    external = "80"
  }

  ports {
    protocol = "tcp"
    internal = 443
    external = 443
  }
}

resource "docker_image" "image-jellyfin" {
  name = "lscr.io/linuxserver/jellyfin"
}

resource "docker_container" "container-jellyfin" {
  name = "container-jellyfin"
  image = docker_image.image-jellyfin.image_id
  must_run = true
  ports {
    internal = 8096
    external = 8096
  }
  env = ["PUID=1000", "PGID=1000", "TZ=Etc/UTC"]
  volumes {
    host_path = "/opt/containers/jellyfin/config"
    container_path = "/config"
  }
  volumes {
    host_path = "/media/tvshows/"
    container_path = "/data/tvshows"
  }
}

locals {
  windows_port_mappings = [
    {port=8006, protocol="tcp"},
    {port=3389, protocol="tcp"},
    {port=3389, protocol="udp"}
  ]
}

resource "docker_image" "image-windows" {
  name = "dockurr/windows"
}

resource "docker_container" "container-windows" {
  name = "container-windows"
  image = docker_image.image-windows.image_id
  env = ["VERSION=2025", "DISK_SIZE=70G", "RAM_SIZE=8G", "CPU_CORES=4", "USERNAME=oa", "PASSWORD=changeme", "LANGUAGE=English", "REGION=en-US", "KEYBOARD=en-US"]
  devices {
    host_path = "/dev/kvm"
    container_path = "/dev/kvm"
    permissions = "rmw"
  }

  devices {
    host_path = "/dev/net/tun"
    container_path = "/dev/net/tun"
    permissions = "rmw"
  }
  dynamic "ports" {
      for_each = local.windows_port_mappings
      content {
        internal = ports.value.port
        external = ports.value.port
        protocol = ports.value.protocol
      }
    }
}

