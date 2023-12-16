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