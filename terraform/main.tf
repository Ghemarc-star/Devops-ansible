terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "ansible_network" {
  name                    = "ansible-network"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "ansible_subnet" {
  name          = "ansible-subnet"
  network       = google_compute_network.ansible_network.id
  region        = var.region
  ip_cidr_range = "10.0.0.0/16"
}

resource "google_container_cluster" "ansible_cluster" {
  name     = "ansible-cluster"
  location = var.region
  
  enable_autopilot = true
  
  network    = google_compute_network.ansible_network.id
  subnetwork = google_compute_subnetwork.ansible_subnet.id
  
  deletion_protection = false
}

output "cluster_name" {
  value = google_container_cluster.ansible_cluster.name
}

output "cluster_location" {
  value = google_container_cluster.ansible_cluster.location
}
