# Proving the Image

**By the end of this chapter you can take
any finished build — this lab's or one of
your own — and check, from the outside,
that it contains what the template
promised.** The checks are the chapter:
an inventory that lists the expected
files, a permission that changed on
purpose, a checksum that matches, and a
receipt that agrees with the copy the
build downloaded itself.

A build log is a claim, not a proof. The
log in chapter 5 says the upload happened
and the script ran; but the first build
in this guide's lab also *said* the
upload happened, while laying the files
out somewhere the next step could not
find (transcript `t05`). The habit this
chapter teaches is the one the whole
series runs on: do not ask the build what
it did. Look at what it left behind.

## The inventory the build writes about itself

The lab's shell step ends by writing a
list of its own work into the artifact:

```bash
find $STAGE_DIR -type f | sort > $STAGE_DIR/inventory.txt
```

After a clean build (transcript `t10`),
that list is the expected six files —
build-info, banner, motd, inventory
itself, and the application's two files —
and nothing else. An inventory like this
costs one line in the template and pays
for itself the first time a build
silently omits a file: the absence is
visible in the artifact, not buried in a
scroll of log. Real images use the same
idea at larger scale — a package list, a
version file, a manifest of contents.

## Permissions: the change that leaves evidence

The payload's `start.sh` sits in the
template folder at mode 660 — not
executable. The build's shell step runs
`chmod 755` on the staged copy. Afterwards
(transcript `t10`):

```text
-rwxr-xr-x 1 root root 161 ... /root/packer-stage/opt/app/start.sh
-rw-rw---- 1 root root 161 ... files/rootfs/opt/app/start.sh
```

The staged copy is executable; the source
is untouched. That is a provisioner
effect you can verify without trusting
anybody's log — including Packer's.

## Checksums: the file is the file

`server.conf` is supposed to arrive
byte-for-byte — the file provisioner
copies; it must not edit. `sha256sum`
both ends and compare (transcript `t10`):

```text
dd815078b460e745972412a2630ae8801345213b261cc3ebfbdc2a9b72fe8013  /root/packer-stage/opt/app/server.conf
dd815078b460e745972412a2630ae8801345213b261cc3ebfbdc2a9b72fe8013  files/rootfs/opt/app/server.conf
```

Identical hashes: the staged file is the
source file. Where a provisioner *should*
transform a file — a template rendered
with the build's values — check the
content instead, the way chapter 7 read
`build-info.txt` for the winning release
number.

## The manifest: the build's receipt

The manifest post-processor writes
`packer-manifest.json` after every build.
From the default build (transcript `t06`):

```json
{
  "name": "base",
  "builder_type": "null",
  "build_time": 1793341512,
  "files": null,
  "artifact_id": "Null",
  "custom_data": {
    "image_name": "basebox",
    "release": "1.0.0"
  }
}
```

Read it with a sceptic's eye. It records
the builder, the time, and the custom
data the template chose to include — and
for the null builder, `files: null` and
`artifact_id: "Null"`, because no image
file exists. A real builder fills those
fields with the images it registered.
Two more cautions, both learned in the
lab: the manifest is overwritten by each
build, so it describes the *most recent*
run only (the lab's copy finished the day
describing the variable experiments, not
the first build), and the downloaded
`collected/build-info.txt` has the same
property — after the chapter 7 builds it
held release 3.0.0 while the original
stage folder still said 1.0.0. Keep
receipts per build, in per-build folders,
if you mean to compare builds later.
That discipline — not any single tool —
is what makes an image pipeline auditable.
