# What Packer Is

You need a machine with a known setup: a
web server with the right packages, a
build worker with the right tools, a
kiosk with the right application. The
hand way is to install an operating
system, log in, and spend an hour typing
the setup from a list — or worse, from
memory. The result works, but it has
three quiet faults. It is slow, because
the hour is paid again for every machine.
It drifts, because no two sittings type
exactly the same thing. And it is
unwritten, because the real description
of the machine is the machine itself.

**Packer is a tool from HashiCorp that
turns the setup into a file and the file
into an image.** You write a **template**
— a text file in a language called HCL —
that names a starting point and the steps
to perform on it. Packer starts a fresh
machine from that starting point, connects
to it, performs the steps, shuts it down,
and saves the result as an **image**: a
frozen, launchable copy of the whole
machine. Build once, launch many times.
Every launch is identical, because every
launch is the same frozen copy.

The image you get this way is often
called a **golden image**: the one
approved pattern from which real machines
are stamped. When the setup needs to
change, you do not visit every machine —
you edit the template, build a new image,
and launch from that. The template is
the record of what your machines are,
and it can sit in version control next to
the rest of your code, where changes are
reviewed and history is kept.

## A first taste

A template names a **builder** (where the
machine runs), some **provisioners** (the
steps), and produces an image. Schematically:

```hcl
source "amazon-ebs" "web" {
  # ...where to start, and how to log in...
}

build {
  sources = ["source.amazon-ebs.web"]

  provisioner "shell" {
    inline = ["apt-get update", "apt-get install -y nginx"]
  }
}
```

`packer build` on that file would start a
cloud instance, run the two commands on
it, and register the result as a machine
image. That particular builder needs a
cloud account and is documented-only in
this guide (chapter 9). Chapter 5 runs
the same shape of template — file uploads
and shell commands instead of just two
commands — against a builder that needs
nothing but an SSH server, and chapter 8
proves what it did. The check, if you
have Packer installed already, is simply
that a template is a plain text file you
can read end to end: the one this guide
builds for real is `packer-lab/image.pkr.hcl`.

## What it is not

Packer is not a deployment tool: it makes
images, and launching them — choosing how
many, where, with what networking — is
somebody else's job, usually Terraform's
(chapter 11). It is not a configuration
manager: it runs its steps once, at build
time, and never visits the machine again;
keeping a running machine in shape over
months is Ansible's territory. It is not
a container tool, though one of its
builders makes container images
(chapter 9). And it is not fast magic:
a build takes as long as the steps take,
and a bad template fails the way a bad
script fails — chapter 13 keeps the
receipts.

## Who it is for

The small-team operator who stamps out
identical servers and is tired of drift.
The cloud user who wants new instances to
arrive already configured, not configure
themselves on first boot. The maker who
builds a Raspberry Pi or VM image once
and rebuilds it cleanly whenever it
changes. The common thread is one person
with a setup they can describe — and who
would like the description, not their
memory, to be the source of truth.
