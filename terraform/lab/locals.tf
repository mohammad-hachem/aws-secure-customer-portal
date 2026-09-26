locals {
  subnets = {
    public-a = {
      cidr = "10.20.0.0/24"
      az   = var.availability_zones[0]
      tier = "public"
    }

    public-b = {
      cidr = "10.20.1.0/24"
      az   = var.availability_zones[1]
      tier = "public"
    }

    app-private-a = {
      cidr = "10.20.10.0/24"
      az   = var.availability_zones[0]
      tier = "application"
    }

    app-private-b = {
      cidr = "10.20.11.0/24"
      az   = var.availability_zones[1]
      tier = "application"
    }

    db-private-a = {
      cidr = "10.20.20.0/24"
      az   = var.availability_zones[0]
      tier = "database"
    }

    db-private-b = {
      cidr = "10.20.21.0/24"
      az   = var.availability_zones[1]
      tier = "database"
    }
  }
}
