terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "2.5.2"
    }
  }
}

variable "linodeapikey" {
  description = "Linode API token"
  type        = string
}

provider "linode" {
  token = "xxxxxxxxxxxxxxxx"
}

variable "videofile" {
  description = "Video filename"
  type        = string
}

variable "machinetype" {
  description = "Machinetype"
  type        = string
  default     = "g6-dedicated-8"
}

variable "machinecount" {
  description = "Number of machines"
  type        = string
  default     = "10"
}

variable "region" {
  description = "Region to run in, make sure you can access storage"
  type        = string
  default     = "se-sto"
}

variable "public_key" {
  description = "Public key for admin access to the ffmpeg machines"
  type        = string
}

variable "random" {
  description = "A random string for naming machines"
  type        = string
}

variable "objectkeys" {
  description = "Keys for object storage"
  type        = string
}

variable "storagebaseurl" {
  description = "Base region for storage"
  type        = string
  default     = "https://se-sto-1.linodeobjects.com"
}

variable "rootpassword" {
  description = "Password for root on the transcoder machines"
  type        = string
}

variable "logfile" {
  description = "Location of logfile"
  type        = string
}

resource "linode_instance" "ffmpeg_instance" {
  count            = var.machinecount
  label            = "ffmpeg-instance-${var.random}-${count.index + 1}"
  image            = "linode/ubuntu22.04"
  region           = var.region
  type             = var.machinetype
  root_pass        = var.rootpassword
  private_ip       = false
  authorized_keys  = [ var.public_key ] 
  tags             = ["transcode"]

  provisioner "file" {
    source      = "ffmpeg_script.sh"
    destination = "/tmp/ffmpeg_script.sh"
  }

    connection {
      type     = "ssh"
      user     = "root"
      password = var.rootpassword
      host     = self.ip_address
    }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ffmpeg_script.sh",
      "apt-get update",
      "sudo apt install -y s3fs",
      "sudo mkdir -p /mnt/transcoding",
      "echo ${var.objectkeys} > ~/.passwd-s3fs",
      "sudo chmod 600 ~/.passwd-s3fs",
      "echo 'transcoding /mnt/transcoding fuse.s3fs _netdev,allow_other,use_path_request_style,nonempty,url=${var.storagebaseurl} 0 0' | sudo tee -a /etc/fstab",
      "sudo mount -a",
      "apt-get install -y ffmpeg",
      "echo Hello > /mnt/transcoding/output/logfile.log",
      "/tmp/ffmpeg_script.sh /mnt/transcoding/intake/${var.random} ${var.videofile}_${count.index + 1}.txt",
    ]

    connection {
      type     = "ssh"
      user     = "root"
      password = var.rootpassword
      host     = self.ip_address
    }
  }
}
