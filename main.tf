resource "google_compute_network" "vpc_network" {
  name = "kubernetes-the-hard-way"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name = "kubernetes"
  ip_cidr_range = "10.240.0.0/24"
  region = "us-east1"
  network = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "vpc_firewall" {
  name = "kubernetes-the-hard-way-allow-internal"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    #ports = ["22", "6443"]
  }
  allow {
    protocol = "udp"
  }
  source_ranges = ["10.240.0.0/24","10.200.0.0/16"]
}

resource "google_compute_firewall" "vpc_firewall_external" {
  name = "kubernetes-the-hard-way-allow-external"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = ["22", "6443"]
  }
  #allow {
  #  protocol = "udp"
  #  ports = ["53"]
  #}
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "vpc_address" {
  name = "kubernetes-the-hard-way"
  region = "us-east1"
}
resource "google_compute_instance" "controller" {
  count = 3
  name = "controller-${count.index}"
  machine_type = "e2-standard-2"
  zone = "us-east1-b"
  tags = ["kubernetes-the-hard-way", "controller"]
  can_ip_forward = true
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-bionic-v20200414"
      size = 200
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.id
    network_ip = "10.240.0.1${count.index}"
    subnetwork = google_compute_subnetwork.vpc_subnetwork.id
    access_config {
      nat_ip = google_compute_address.vpc_address[count.index].address
    }
  }
  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }
}

# Worker Nodes
resource "google_compute_instance" "worker" {
  count = 3
  name = "worker-${count.index}"
  machine_type = "e2-standard-2"
  zone = "us-east1-b"
  tags = ["kubernetes-the-hard-way", "worker"]
  can_ip_forward = true
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-bionic-v20200414"
      size = 200
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.id
    network_ip = "10.240.0.2${count.index}"
    subnetwork = google_compute_subnetwork.vpc_subnetwork.id
    access_config {
      nat_ip = google_compute_address.vpc_address[count.index].address
    }
  }

  metadata = {
    pod-cidr = "10.200.${count.index}.0/24"
  }
  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }
}