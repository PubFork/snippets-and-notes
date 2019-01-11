provider "aws" {
  version = "~> 1.5"

  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

provider "dnsimple" {
  version = "~> 0.1"
}

resource "aws_instance" "web" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = "${var.vpc_security_group}"
  key_name               = "${aws_key_pair.key.id}"
  count                  = "${var.num_webs}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Identity = "..."
    Name     = "${var.label} ${count.index + 1}/${var.num_webs}"
    Zip      = "zap"
  }

  connection {
    user        = "ubuntu"
    private_key = "${file("/home/matt/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "assets"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = ["sudo sh /tmp/assets/setup-web.sh"]
  }
}

resource "aws_key_pair" "key" {
  key_name   = "${var.identity}-key"
  public_key = "${file("/home/matt/.ssh/id_rsa.pub")}"
}

resource "dnsimple_record" "web" {
  domain = "hashicorp.com"
  name   = "web"
  ttl    = "3600"
  type   = "A"
  value  = "${aws_instance.web.0.public_ip}"
}
