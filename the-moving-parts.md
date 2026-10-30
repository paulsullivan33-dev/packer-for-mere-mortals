# The Moving Parts

**By the end of this chapter you can look
at any Packer template and say which part
does what.** The check: open
`packer-lab/image.pkr.hcl` and find one
block of each kind named below — a
variable, a source, a build, two kinds of
provisioner, and a post-processor. Every
one of them is in that one file.

A Packer build has six parts. Five of
them you write; one of them Packer
fetches.

## The template

The **template** is the file itself —
usually named something ending in
`.pkr.hcl`. It is written in **HCL**,
HashiCorp's configuration language: blocks
with labels, settings as `name = value`,
and references like `var.release` that
pull values from variables. JSON templates
exist from Packer's early days; new work
uses HCL, and this guide does throughout.
Chapter 4 takes one apart line by line.

## Variables

A **variable** is a named value with a
default, declared at the top of the
template and used anywhere as `var.name`.
Variables are how one template builds a
test image on Monday and a release image
on Friday: the steps stay the same, the
values change. Chapter 7 shows the four
ways to supply a value — default, file,
environment, command line — and proves
which one wins by reading the finished
artifact.

## Sources and builders

A **source** block describes one kind of
machine to build on: `source "null" "base"`
is the null builder's instance named
`base`; `source "amazon-ebs" "web"` would
be a cloud one. Behind every source type
is a **builder** — the code that knows how
to start that kind of machine, connect to
it, and save the result as an image.
Builders are the part of Packer that
touches the outside world, and the part
that differs most between a home lab and
a cloud account (chapter 9).

## The communicator

Packer does not reach into the machine by
magic. It connects with a **communicator**
— almost always **SSH** on Linux machines
(WinRM is the Windows equivalent), using
the address and key the source block
gives it. Everything a provisioner does
arrives over that connection, exactly as
if a person had logged in. This is why
chapter 5 can substitute an ordinary SSH
server for a cloud: to the provisioners,
there is no difference.

## Provisioners

A **provisioner** is one setup step, run
in order inside the build block. This
guide runs three kinds for real:

- **file** — copy files in (or, with
  `direction = "download"`, copy results
  back out).
- **shell** — run commands on the machine,
  either a script file or lines written
  inline in the template.
- Others exist — Ansible itself can be a
  provisioner, for example — and are
  covered as neighbours in chapter 11.

Chapter 6 is theirs.

## Post-processors

After the machine is saved, a
**post-processor** can work on the
result: compress it, checksum it, upload
it somewhere, or — the one this guide runs
— write a **manifest**, a JSON receipt
naming what was built and when. Chapter 8
reads one.

## Plugins

Builders, provisioners and post-processors
all reach Packer as **plugins**: separate
programs Packer downloads and runs. Some
are **bundled** inside Packer itself — the
null builder, the file and shell
provisioners, and the manifest
post-processor among them — and need
nothing. The rest are declared in a
`packer { required_plugins { ... } }`
block and fetched by `packer init`.
Chapter 4 shows both halves of that story,
including the error you get when you ask
init to fetch a plugin that turns out to
be bundled already.
