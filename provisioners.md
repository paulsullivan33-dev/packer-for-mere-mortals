# Provisioners

**By the end of this chapter you can
write the two provisioners that do most
real work — file and shell — and predict
exactly where an uploaded folder's
contents will land.** The check: the
staged tree in transcript `t06` matches
the layout this chapter describes, file
for file.

Provisioners run in the order they are
written, inside the build, over the
communicator's connection. The lab's
build has three: file up, shell, file
down.

## The file provisioner, going up

```hcl
provisioner "file" {
  source      = "${path.root}/files/"
  destination = var.stage_dir
}
```

This copies the template's `files/`
folder to `packer-stage` on the target.
Simple to write — and the source of this
guide's one failed build, so learn its
layout rules from evidence, not from the
shape of the command.

The lab's first payload was laid out the
obvious way — `files/etc/banner.txt`,
`files/opt/app/…` — and the build failed
when the shell step could not find
`packer-stage/opt/app/start.sh`
(transcript `t05`). Looking at what had
actually arrived showed why. Given a
folder as its source, the file
provisioner **pours the contents of each
folder inside the source into the
destination** — it does not preserve the
source's own structure. `files/etc/…`
arrived as `packer-stage/banner.txt`
(the `etc` level gone); `files/opt/app/…`
arrived as `packer-stage/app/…` (the
`opt` level gone). A controlled probe
with a deeper test tree confirmed the
rule and added a sharper one (the probe
is described in `criteria.md`): a plain
file sitting at the top of the source
folder was not carried across at all.

So the lab's payload carries one folder,
named for what it is — the image's root
filesystem:

```text
files/
  rootfs/
    etc/banner.txt
    opt/app/server.conf
    opt/app/start.sh
```

One folder in, its contents poured out:
`rootfs` disappears into the destination,
and `etc/` and `opt/` land exactly where
an image wants them (transcript `t06`).
Treat this as the pattern, whatever
builder you use: **give the file
provisioner one folder whose contents
are the layout you want.**

The second rule is about the destination.
Build twice into the same stage folder
and the second upload does not replace
the first — it adds a nested copy beside
it (transcript `t09`:
`packer-stage/rootfs/etc/banner.txt`
appearing next to the original
`packer-stage/etc/banner.txt`). Packer
never deletes from the target. Build
into a **fresh destination** every time —
a new folder, or an emptied one — or your
image quietly accumulates the last build's
leavings.

## The shell provisioner

```hcl
provisioner "shell" {
  environment_vars = [
    "IMAGE_NAME=${var.image_name}",
    "RELEASE=${var.release}",
    # ...
  ]
  inline = [
    "mkdir -p $STAGE_DIR/etc",
    "printf '%s\\n' \"$MOTD_MESSAGE\" > $STAGE_DIR/etc/motd",
    # ...
  ]
}
```

Packer joins the `inline` lines into one
script, uploads it to the target, and
runs it there. Three properties matter:

- **Variables do not cross by themselves.**
  Template values reach the script only
  through `environment_vars`, which Packer
  sets from the template's variables —
  this is the seam where chapter 7's
  values become chapter 6's behaviour.
- **Its output is your output.** Anything
  the script prints appears in the build
  log as it runs — the build's
  `staged basebox release 1.0.0` line is
  the script's own `echo`.
- **A failed line fails the build.** The
  `chmod` that could not find its file in
  transcript `t05` stopped the build on
  the spot, with "Provisioning step had
  errors". Treat a provisioner failure as
  the build telling you the truth early.

A script file works too (`script = "setup.sh"`
instead of `inline`), and is the better
shape for anything long; inline is for
steps you want visible in the template
itself.

## The file provisioner, coming down

The same provisioner runs in reverse:

```hcl
provisioner "file" {
  source      = "${var.stage_dir}/build-info.txt"
  destination = "${path.root}/collected/build-info.txt"
  direction   = "download"
}
```

Downloads are how build results — logs,
test reports, and here the build-info
receipt — get back to the machine running
Packer, where later steps (and chapter
8's checks) can see them. With a real
builder this is also the honest limit of
access: once the image is saved and the
machine destroyed, what you did not
download is gone.
