# The Neighbours

**By the end of this chapter you can say
where Packer stops and each neighbouring
tool starts.** These tools are
characterised from their documentation
and this series' own guides, not
benchmarked; the one overlap the lab ran
for real — Ansible's world versus
Packer's — it ran only as far as the
shell provisioner, and it says so.

## Terraform: launches what Packer bakes

The closest neighbour, from the same
company. Terraform describes running
infrastructure — networks, machines,
storage — and brings it into being;
Packer describes the inside of one
machine's disk and freezes it. The
standard partnership: Packer builds the
image, the image's ID lands in a
variable, Terraform launches instances
from it. Neither does the other's job,
and using one where the other belongs
(terraforming a machine's contents, or
hand-baking what should be launched)
is the commonest design smell in this
territory. The Terraform guide in this
series is the companion read.

## Ansible: keeps machines in shape, forever

Ansible describes a machine's state and
re-applies the description whenever you
run it — next week, next year, after
someone's manual change. Packer applies
its steps exactly once, before the image
exists. That difference is the whole
boundary. Many teams use both: Ansible
playbooks as the provisioner inside a
Packer build, so the image is baked by
the same description that maintains the
fleet. Many use Ansible *instead*, and
give up the golden image for machines
that converge on boot or on a schedule.
Which trade suits you depends on how
often machines are replaced versus
repaired. The Ansible guide in this
series covers the convergence side.

## Docker and Dockerfiles: the container cousin

A Dockerfile is also a written recipe
that produces an image — but a container
image is a filesystem and a config, not
a bootable machine, and its build runs
no VM and usually no SSH. If your
deliverable runs under Docker, the
Dockerfile is the simpler tool and
Packer's Docker builder (chapter 9) is
mostly for teams who want one pipeline
for both kinds of image. The Docker
guide in this series starts from the
Dockerfile side.

## cloud-init: configuration at first boot

cloud-init runs once when a fresh
instance first boots, applying the
configuration it is handed. It is the
golden image's mirror image: instead of
baking everything in beforehand, launch
a plain image and configure on arrival.
First-boot configuration keeps images
small and generic, but every launch pays
the setup time, and a machine's real
configuration exists only after boot —
Packer's whole chapter 8 audit story
depends on the artifact existing before
anything launches. Serious setups often
combine them: Packer bakes the heavy,
slow parts; cloud-init applies the
per-instance details.

## Vagrant: the development sibling

Also HashiCorp's. Vagrant manages local
development VMs from written files, and
can use a Packer-built box as its
starting point. Where Packer's product
is the image, Vagrant's is the running
machine you work in. Developers who live
in Vagrantfile environments are Packer's
most natural audience when those
environments need to become repeatable
for a whole team.

## Doing it by hand: still a neighbour

The honest baseline. Hand setup costs
nothing to adopt and everything to
repeat: time, drift, and the absence of
a record. Packer earns its learning
curve the second time you need the same
machine — and, per chapter 5, it can be
learned and tested on one ordinary
workstation before any cloud or
hypervisor is involved.
