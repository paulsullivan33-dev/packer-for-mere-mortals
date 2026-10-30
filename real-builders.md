# Real Builders

**Everything in this chapter is
documented-only.** The lab had no
hypervisor (no `/dev/kvm`), no container
runtime, and no cloud account, so none of
these builders was run. What follows is
drawn from HashiCorp's documentation and
labelled as such, in line with this
guide's criteria. By the end of it you
can say what changes — and what does not
— when the machine being built is real.

What does not change is the shape of the
work. Every builder below still takes a
source block, the communicator still
connects (usually by SSH), the same file
and shell provisioners run in the same
order, variables work the same way, and
the manifest post-processor still writes
its receipt — with the `files` and
`artifact_id` fields filled in this time.
Everything in chapters 4, 6, 7 and 8
carries over. What changes is where the
machine comes from, what the finished
image *is*, and which plugin `packer
init` must fetch first.

## QEMU: a virtual machine on your own desk

The QEMU builder (`source "qemu"`) runs a
virtual machine under QEMU/KVM, installs
from an ISO you supply, and saves the
result as a disk image file. Its source
block names the ISO and its checksum, the
disk size, memory and CPUs, and — the
part with no equivalent in this guide's
lab — a **boot command**: a scripted
sequence of keystrokes and waits that
drives the installer's menus, because a
fresh ISO does not yet have SSH running
for the communicator to reach. Expect to
iterate on that sequence; it is the
fiddliest part of any ISO-based build.
QEMU images suit VM fleets, appliances,
and — with a different disk format — the
single-board and embedded worlds. The lab
could not run it for one concrete reason,
shown in transcript `t00`: its machine
has no `/dev/kvm`, the kernel device
hardware virtualisation needs.

## Docker: an image without a machine

The Docker builder (`source "docker"`)
starts from a container image instead of
an operating system installer, runs the
provisioners inside the container, and
commits the result as a new image. There
is no boot and usually no SSH —
provisioners run through Docker's own
exec channel — so builds are fast and
the loop is tight. It is the right tool
when the deliverable is a container, and
the wrong one when it is a bootable
machine. The lab installed this builder's
plugin for real (chapter 4, transcript
`t02`: `packer-plugin-docker_v1.1.4`) but
had no container runtime to build with,
so the builder itself is documented-only
here; the Docker guide in this series
covers the container side.

## The cloud builders: images where they will run

Each cloud has its builder — `amazon-ebs`
for AWS, `azure-arm` for Azure,
`googlecompute` for Google Cloud, and
more — and they all follow one outline.
The source block names a **base image**
to start from (a publisher's clean OS
image plays the role the ISO plays for
QEMU), an instance size, a region, and
credentials, which come from the
environment or the cloud's usual config
files, never written into the template.
Packer starts an instance, provisions it
over SSH exactly as in chapter 5, stops
it, and registers the result as a
launchable image in that cloud, recorded
in the manifest by its cloud ID. The
costs are real but small — minutes of
instance time — and the failure modes are
the ones chapters 6 and 13 teach: most
cloud build failures are still a
provisioner failing on a machine you can
no longer reach, which is why developing
the provisioners first, against the null
builder or a local VM, is the working
pattern this guide recommends.

## Choosing

Build where the image will run, if you
can: a cloud image built by its own
cloud's builder needs no conversion
afterwards. Build locally with QEMU when
the target is a VM you host yourself.
Use Docker's builder for containers. And
use the null builder — this guide's lab
— whenever what you are really developing
is the template.
