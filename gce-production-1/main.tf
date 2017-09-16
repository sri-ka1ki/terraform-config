variable "env" {
  default = "production"
}

variable "gce_bastion_image" {
  default = "eco-emissary-99515/bastion-1478778272"
}

variable "gce_gcloud_zone" {}
variable "gce_heroku_org" {}

variable "gce_worker_image" {
  default = "eco-emissary-99515/tfw-1499625597"
}

variable "github_users" {}
variable "job_board_url" {}

variable "travisci_net_external_zone_id" {
  default = "Z2RI61YP4UWSIO"
}

variable "syslog_address_com" {}
variable "syslog_address_org" {}

terraform {
  backend "s3" {
    bucket         = "travis-terraform-state"
    key            = "terraform-config/gce-production-1.tfstate"
    region         = "us-east-1"
    encrypt        = "true"
    dynamodb_table = "travis-terraform-state"
  }
}

provider "google" {
  credentials = "${file("config/gce-workers-production-1.json")}"
  project     = "eco-emissary-99515"
  region      = "us-central1"
}

provider "aws" {}
provider "heroku" {}

module "gce_project_1" {
  source                        = "../modules/gce_project"
  bastion_config                = "${file("${path.module}/config/bastion-env")}"
  bastion_image                 = "${var.gce_bastion_image}"
  env                           = "${var.env}"
  gcloud_cleanup_account_json   = "${file("${path.module}/config/gce-cleanup-production-1.json")}"
  gcloud_cleanup_job_board_url  = "${var.job_board_url}"
  gcloud_zone                   = "${var.gce_gcloud_zone}"
  github_users                  = "${var.github_users}"
  heroku_org                    = "${var.gce_heroku_org}"
  index                         = "1"
  project                       = "eco-emissary-99515"
  syslog_address_com            = "${var.syslog_address_com}"
  syslog_address_org            = "${var.syslog_address_org}"
  travisci_net_external_zone_id = "${var.travisci_net_external_zone_id}"
  worker_account_json_com       = "${file("${path.module}/config/gce-workers-production-1.json")}"
  worker_account_json_org       = "${file("${path.module}/config/gce-workers-production-1.json")}"
  worker_image                  = "${var.gce_worker_image}"
  worker_instance_count_com     = 12
  worker_instance_count_org     = 16

  public_subnet_cidr_range    = "10.10.1.0/24"
  workers_subnet_cidr_range   = "10.10.16.0/22"
  build_org_subnet_cidr_range = "10.10.20.0/22"
  build_com_subnet_cidr_range = "10.10.24.0/22"

  worker_config_com = <<EOF
### worker.env
${file("${path.module}/worker.env")}
### config/worker-env-com
${file("${path.module}/config/worker-env-com")}

export TRAVIS_WORKER_GCE_SUBNETWORK=workerscom
export TRAVIS_WORKER_HARD_TIMEOUT=120m
export TRAVIS_WORKER_POOL_SIZE=35
export TRAVIS_WORKER_TRAVIS_SITE=com
EOF

  worker_config_org = <<EOF
### worker.env
${file("${path.module}/worker.env")}
### config/worker-env-org
${file("${path.module}/config/worker-env-org")}

export TRAVIS_WORKER_GCE_PUBLIC_IP=true
export TRAVIS_WORKER_GCE_PUBLIC_IP_CONNECT=false
export TRAVIS_WORKER_GCE_SUBNETWORK=buildorg
export TRAVIS_WORKER_POOL_SIZE=30
export TRAVIS_WORKER_TRAVIS_SITE=org
EOF
}
