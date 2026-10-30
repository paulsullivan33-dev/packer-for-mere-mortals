# Building Without a Cloud

**By the end of this chapter a complete
Packer build has run on one ordinary
machine — files uploaded, commands
executed, a result downloaded, a manifest
written.** The check: `packer build`
ends with "Builds finished", and the
staged folder holds the six files chapter
8 will audit one by one.

The problem is access. Most Packer
tutorials start with a cloud account or a
hypervisor, because that is where images
usually get built. But everything a
provisioner does arrives through the
communicator — an SSH login — and Packer
ships a builder that needs nothing on the
other end of that login at all: the **null
builder**. It starts no machine. It simply
connects to an address you give it, runs
the build's provisioners there, and
reports, in its own words, that it "did
not export anything. This is the null
builder." For learning Packer — and for
testing templates and provisioners before
spending cloud money on them — that is
exactly enough.

## The target: an SSH server on loopback

The lab ran a second SSH server on the
same machine, on port 2222, listening
only on 127.0.0.1, key authentication
only, with its own throwaway key
(transcript `t01`):

```text
Port 2222
ListenAddress 127.0.0.1
HostKey <lab folder>/host_key
AuthorizedKeysFile <lab folder>/authorized_keys
PasswordAuthentication no
PubkeyAuthentication yes
```

A plain `ssh -i id_lab -p 2222
root@127.0.0.1` answers with the machine's
hostname before Packer is involved at
all — always prove the door opens by
hand before asking a tool to walk through
it. (One sandbox wrinkle, kept in
transcript `t01`: sshd first refused to
start because `/run/sshd` had the wrong
permissions. Chapter 13 lists it; on a
normal machine the distribution's own
sshd is already running and you can point
the template at that instead.)

The template's source block is the other
half of the arrangement:

```hcl
source "null" "base" {
  communicator           = "ssh"
  ssh_host               = "127.0.0.1"
  ssh_port               = var.ssh_port
  ssh_username           = var.ssh_username
  ssh_private_key_file   = "${path.root}/id_lab"
  ssh_timeout            = "1m"
  ssh_handshake_attempts = 20
}
```

`${path.root}` is the template's own
folder — the key sits beside the template
(it is a lab key, generated for this one
job, and it is not in the guide's
repository; generate your own with the
`ssh-keygen` line in transcript `t01`).

## The build

```bash
packer build image.pkr.hcl
```

Nineteen lines of output carry the whole
story (transcript `t06`):

```text
==> basebox.null.base: Using SSH communicator to connect: 127.0.0.1
==> basebox.null.base: Waiting for SSH to become available...
==> basebox.null.base: Connected to SSH!
==> basebox.null.base: Uploading ./files/ => packer-stage
==> basebox.null.base: Provisioning with shell script: /tmp/packer-shell896189361
==> basebox.null.base: staged basebox release 1.0.0 into packer-stage
==> basebox.null.base: Downloading packer-stage/build-info.txt => ./collected/build-info.txt
==> basebox.null.base: Running post-processor:  (type manifest)
Build 'basebox.null.base' finished after 190 milliseconds 102 microseconds.
```

Read it as the build's own claims: it
connected, uploaded the payload, ran the
shell step (whose `echo` line — "staged
basebox release 1.0.0 into packer-stage" —
is printed verbatim, because provisioner
output is shown as it happens), downloaded
one file back, and recorded the manifest.
The finish line names the honest limit of
the null builder: no image was exported,
because there was never a machine to
image. What stands in for the image is
the staged folder, `packer-stage` in the
SSH login's home — a small pretend root
filesystem holding a banner, an
application's settings and launcher, the
message of the day, a build-info file,
and an inventory. Whether those claims
are true is not this chapter's word to
take: chapter 8 checks every one.

Two practical notes. Builds are quick
here because nothing boots; a real
builder spends most of its time waiting
for a real machine. And the build does
not tidy up its target: what the
provisioners wrote stays written, which
chapter 6 shows can surprise you on a
second build.
