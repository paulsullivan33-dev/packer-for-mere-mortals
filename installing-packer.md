# Installing Packer

**By the end of this chapter Packer is
installed and you have checked it two
ways: the download is genuine, and the
program runs.** The checks are the
chapter: a checksum that matches
HashiCorp's published value, and one
command that prints the version.

Packer is a single program, written in Go
and distributed by HashiCorp from
`releases.hashicorp.com`. There are
packages for the usual Linux distributions
and archives for everything else. The lab
used the archive, because it works the
same everywhere and keeps the whole
install in one folder you can delete:

1. Download `packer_1.16.2_linux_amd64.zip`
   and the matching `packer_1.16.2_SHA256SUMS`
   file from the 1.16.2 folder on the
   releases site. (Use the current version
   when you read this; the steps do not
   change.)
2. Check the archive against the sums file
   before unzipping anything:

```bash
grep linux_amd64 packer_1.16.2_SHA256SUMS
sha256sum packer_1.16.2_linux_amd64.zip
```

The two hashes must be identical — in the
lab both were
`abbfe0cf74985084112659b53e3565f264f70a20914c3b7c4f789f54f61c2414`
(transcript `t00`). This is the same
habit as checking any download that will
run with your privileges: the sums file
is HashiCorp's statement of what the
archive should contain, and thirty
seconds with `sha256sum` confirms your
copy is that archive.

3. Unzip, and run the binary in place:

```bash
unzip packer_1.16.2_linux_amd64.zip
./packer version
```

```text
Packer v1.16.2
```

That line is the install's proof. Put the
binary somewhere on your `PATH` (for
example `~/bin` or `/usr/local/bin`) when
you are ready to keep it; the lab ran it
from its own folder throughout, which is
why transcripts call `./packer`'s full
path.

Two honest notes. First, Packer by
default phones home once per command with
an anonymous version check (HashiCorp
calls it Checkpoint). Setting the
environment variable `CHECKPOINT_DISABLE=1`
turns that off; the lab ran with it off,
and the transcripts are cleaner for it.
Second, this sandbox's clock and
resources are shared with other work, so
build times quoted in this guide are the
lab's, not a promise about yours — the
example build is small enough that the
difference will not matter.
