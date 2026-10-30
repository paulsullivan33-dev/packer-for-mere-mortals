# A template that does nothing but declare an external plugin, so that
# `packer init init-demo.pkr.hcl` has something real to download.
# The docker builder itself is documented-only in this guide: the lab
# has no container runtime to build with. Installing its plugin works
# fine, and that install is all this file exists to prove.
packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = ">= 1.0.0"
    }
  }
}
