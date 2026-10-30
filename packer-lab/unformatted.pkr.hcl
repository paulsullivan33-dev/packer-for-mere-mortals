# basebox — an example image built with Packer's bundled "null" builder.
# Everything this template uses (the null builder, the file and shell
# provisioners, the manifest post-processor) ships inside Packer itself,
# so it needs no required_plugins block and nothing for init to download.
# Templates that use cloud or hypervisor builders declare those plugins
# in a packer {} block instead — init-demo.pkr.hcl in this folder shows one.

variable "image_name" {
  type    = string
  default = "basebox"
}

variable "release" {
  type    = string
  default = "1.0.0"
}

variable "motd_message" {
  type    = string
  default = "Authorised users only. All activity is logged."
}

variable "stage_dir" {
  type    = string
  default = "packer-stage"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "ssh_port" {
  type    = number
  default = 2222
}

source "null" "base" {
  communicator = "ssh"
  ssh_host               = "127.0.0.1"
  ssh_port= var.ssh_port
  ssh_username           = var.ssh_username
  ssh_private_key_file   = "${path.root}/id_lab"
  ssh_timeout      =   "1m"
  ssh_handshake_attempts = 20
}

build {
  name    = var.image_name
  sources = ["source.null.base"]

  provisioner "file" {
    source      = "${path.root}/files/"
    destination = var.stage_dir
  }

  provisioner "shell" {
    environment_vars = [
      "IMAGE_NAME=${var.image_name}",
      "RELEASE=${var.release}",
      "MOTD_MESSAGE=${var.motd_message}",
      "STAGE_DIR=${var.stage_dir}",
    ]
    inline = [
      "mkdir -p $STAGE_DIR/etc",
      "printf '%s\\n' \"$MOTD_MESSAGE\" > $STAGE_DIR/etc/motd",
      "printf 'image=%s\\nrelease=%s\\nbuilt_by=packer\\n' \"$IMAGE_NAME\" \"$RELEASE\" > $STAGE_DIR/build-info.txt",
      "chmod 755 $STAGE_DIR/opt/app/start.sh",
      "find $STAGE_DIR -type f | sort > $STAGE_DIR/inventory.txt",
      "echo \"staged $IMAGE_NAME release $RELEASE into $STAGE_DIR\"",
    ]
  }

  provisioner "file" {
    source      = "${var.stage_dir}/build-info.txt"
    destination = "${path.root}/collected/build-info.txt"
    direction   = "download"
  }

  post-processor "manifest" {
    output     = "${path.root}/packer-manifest.json"
    strip_path = true
    custom_data = {
      image_name = var.image_name
      release    = var.release
    }
  }
}
