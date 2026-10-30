# Packer for Mere Mortals

Set up a machine by hand and you get a
machine. Set up ten by hand and you get
ten *almost* identical machines, each
with its own small differences, and no
written record of any of them. Six months
later nobody can say why one works and
another does not, and building an
eleventh means starting from memory.

**Packer** replaces the hand work with a
**template**: one written file that says
what a machine image should contain.
Packer starts a blank machine — in a
cloud, in a hypervisor, in a container —
follows the template's instructions to
install and arrange everything, and saves
the result as an **image** you can launch
as many times as you like. Every launch
is the same machine, because every launch
came from the same written description.
The description is the record, and it can
be kept, reviewed and changed like code.

This guide explains how a Packer template
is put together, then does something most
image-building guides cannot: it runs a
complete build in a lab that has **no
cloud account, no hypervisor and no
container runtime**, and proves the
result file by file. Packer ships a
**null builder** that builds against any
machine reachable by SSH. The lab points
it at an SSH server on the same machine,
so the full machinery — uploading files,
running setup commands over SSH,
downloading results, recording a
manifest — runs for real, against a
staged folder that stands in for the
image. Everything the build claims to
have done is then checked by hand:
inventories, permissions, checksums.

The lab ran **Packer 1.16.2**, the
official HashiCorp binary, verified
against HashiCorp's published checksums
before it was run. It installed one real
external plugin (the Docker plugin, by
`packer init`) to prove how plugins
arrive, formatted and validated
templates, broke one on purpose to see
the error, and ran the example build
four times — once with default values,
and then with variables supplied by a
file, by the environment and by the
command line, each time showing the
difference in the finished artifact.
One build failed along the way, because
the file upload did not lay files out
the way the template assumed. The
failure is kept, explained, and fixed
in the open; it teaches more about the
file provisioner than the successes do.

What the lab could not do, it did not
fake. Its machine had no `/dev/kvm`, so
no virtual machine was ever booted, and
no container runtime, so the Docker
builder was never run. It had no cloud
account, so no cloud image was built.
Those builders — QEMU, Docker, and the
clouds — are taught from HashiCorp's
documentation in chapter 9 and labelled
as documented-only wherever they appear.
`criteria.md` keeps the full ledger of
what was run and what was only read.

## What this guide covers

- [**What Packer is**](what-packer-is.md) —
  the golden-image idea: one template,
  many identical machines, and why a
  written description beats a remembered
  procedure
- [**The moving parts**](the-moving-parts.md) —
  templates, builders, communicators,
  provisioners, post-processors and
  plugins, and which part holds what
- [**Installing Packer**](installing-packer.md) —
  the official download, the checksum
  check that proves it is genuine, and
  the version check that proves it runs
- [**Your first template**](your-first-template.md) —
  the anatomy of an HCL template, and
  `packer fmt`, `packer validate` and
  `packer inspect` — plus `packer init`
  and the plugin it really downloads
- [**Building without a cloud**](building-without-a-cloud.md) —
  the null builder and a loopback SSH
  server: a complete, real build on one
  ordinary machine
- [**Provisioners**](provisioners.md) —
  the file provisioner in both
  directions, the shell provisioner, and
  the upload layout rules the lab
  learned the hard way
- [**Variables**](variables.md) —
  defaults, variable files, environment
  variables and command-line values, and
  which one wins — proved in the
  artifact, not just asserted
- [**Proving the image**](proving-the-image.md) —
  how to know a build really did what it
  claims: the inventory it writes, file
  permissions, checksums, and the
  manifest post-processor
- [**Real builders**](real-builders.md) —
  QEMU, Docker and the cloud builders:
  what changes when the machine is real
  (documented-only in this guide)
- [**Recipes**](recipes.md) — a dated
  image name, a variables file per
  environment, a checksum post-processor,
  and keeping templates in version control
- [**The neighbours**](the-neighbours.md) —
  Terraform, Ansible, Dockerfiles,
  cloud-init and doing it by hand: what
  each does that Packer doesn't, and
  vice versa
- [**Limits**](limits.md) — what Packer
  cannot do: it bakes images, it does not
  run fleets, and a build is only as
  reproducible as its inputs
- [**Troubleshooting**](troubleshooting.md) —
  the plugin that 404s because it is
  bundled, the validate error that names
  your typo, the upload that lands one
  folder over, the nested copy on a
  rebuild, and the other traps this
  guide's lab fell into
- [**Glossary**](glossary.md) — the
  terms, collected in one place

## What it doesn't cover

Building an image in a real cloud
account, or booting one in a real
hypervisor — chapter 9 teaches those
builders' shapes from the documentation,
but this guide's lab built on loopback
only, and it says so wherever it matters.
Packer is one step in a larger pipeline:
deploying the finished image is
Terraform's job, not Packer's, and
keeping running machines in shape
afterwards is a configuration tool's
job. Both neighbours get their chapter,
and both have their own guides in this
series.

## How to use this guide

Read chapter 1 for the idea and chapter
2 before installing anything — knowing
which part holds what turns later
confusion into a named problem. Chapter
3 installs Packer and checks it. Chapter
4 takes a template apart and introduces
the four commands you will use daily.
Chapter 5 runs the whole build on one
machine, and chapters 6 and 7 open up
its two working parts. Chapter 8 is the
one to read slowly: its checks are how
you catch a build that quietly did less
than it claimed. The lab's templates
and transcripts live in `packer-lab/`;
every command in chapters 4 to 8 can be
re-run against them.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [Terraform for Mere Mortals](https://paulsullivan33-dev.github.io/terraform-for-mere-mortals/)
- [Ansible for Mere Mortals](https://paulsullivan33-dev.github.io/ansible-for-mere-mortals/)
- [Virtual Machines for Mere Mortals](https://paulsullivan33-dev.github.io/virtual-machines-for-mere-mortals/)
- [Docker for Mere Mortals](https://paulsullivan33-dev.github.io/docker-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/packer-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/packer-for-mere-mortals/blob/main/LICENSE-CODE).
