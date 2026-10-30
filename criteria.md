# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The lab's example image is an invented "basebox", its payload
   a generic banner, settings file and placeholder launcher.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** Chapter 12 names what the tool
   cannot do: it bakes images and runs no fleet, reproducibility
   is bounded by its inputs, provisioner failures can strand
   machines, the file provisioner's layout rules are its own,
   secrets baked in are secrets published, and the null builder
   proves templates, not bootable images.
8. **The ethics rule is in the text, early.** Image building
   raises no interception question, but it concentrates trust: a
   golden image is launched by everyone who trusts it, so
   chapter 3 insists on verifying the installer's checksum
   before running it, and chapter 12 states plainly that no
   secret belongs in a template or an image. Those two rules
   appear before any procedure depends on them being understood.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The build machine is a 2-CPU, 7.7 GB Ubuntu sandbox (kernel
7.0.0-39), shared with other work while the lab ran. Packer
**1.16.2** was downloaded from releases.hashicorp.com and
verified before use: the archive's SHA-256,
`abbfe0cf74985084112659b53e3565f264f70a20914c3b7c4f789f54f61c2414`,
matches the value in HashiCorp's published
`packer_1.16.2_SHA256SUMS` (transcript t00). All transcripts
live in `packer-lab/transcripts/`; the templates and payload
they ran are beside them in `packer-lab/`. `ls /dev/kvm`
(video acceleration for QEMU) fails on this machine — the
fact that decides chapter 9's ceiling is in transcript t00.

The lab's build target was a second, loopback-only SSH server
on the same machine (port 2222, key authentication only, its
own host key and a throwaway login key generated for the lab;
the private key is not in this repository). The target login
was root on the sandbox itself, home `/root`, which is where
the transcripts' stage folders live.

Run for real, with transcripts as evidence:

- Version, checksum verification of the download, and the
  machine inventory, including the missing `/dev/kvm` (t00).
- The loopback sshd: configuration, first-start failure on
  `/run/sshd` permissions (mode 770; fixed with chmod 755),
  and a hand SSH login returning hostname, user and home
  before Packer was involved (t01).
- Plugin installation both ways: `packer init` asking for the
  bundled null builder as if it were a plugin and receiving
  GitHub's 404 verbatim (the check that the address itself was
  fine: other HashiCorp plugin repositories answer normally),
  then `packer init` on a template declaring the Docker plugin
  installing `packer-plugin-docker_v1.1.4`, confirmed by
  `packer plugins installed` (t02).
- `packer fmt` in full: `-check -diff` printing the diff and
  exiting 3 on an unformatted template, `fmt` rewriting it,
  `-check` then exiting 0 in silence (t03).
- `packer validate` passing the lab template and `packer
  inspect` summarising its variables, build, provisioners and
  post-processor (t04).
- The full build with default values (t06): SSH connect, file
  upload, shell provisioner output shown as it ran, download
  of build-info.txt back to the build machine, and the
  manifest post-processor's JSON — including the null
  builder's own "Did not export anything" line.
- Variables end to end (t07): a var-file build whose artifact
  records release 2.1.0 and the file's motd; a `-var` build
  over the same var-file whose artifact records 3.0.0,
  proving command line beats file; `PKR_VAR_release=9.9.9`
  changing what `packer inspect` reports, proving the
  environment layer.
- A deliberately broken template — `var.releas` for
  `var.release` — caught by `packer validate` with the error
  and exit code 1 verbatim (t08).
- Artifact proof (t10): the inventory the build wrote inside
  its own stage folder; `start.sh` at mode 660 in the payload
  and 755 in the artifact, the shell step's chmod made visible;
  `server.conf` with an identical SHA-256 at source and
  destination; the downloaded build-info diffed identical to
  the staged original.
- Two failures kept as first-class evidence. The first build
  (t05) failed when the shell step could not find
  `opt/app/start.sh`, because the file provisioner pouring a
  folder had dropped the payload's top folder levels; a
  controlled four-file probe tree (a top-level plain file,
  nested folders) pinned the behaviour down: each folder in
  the source has its contents poured into the destination,
  and a plain file at the source's top level was not carried
  across. The payload was restructured under one `rootfs`
  folder, after which the layout was exact. And a second
  build into the same stage folder (t09) nested a fresh
  `rootfs` copy beside the first build's files instead of
  replacing anything — the evidence behind the guide's
  fresh-destination rule.

Documented only — described from HashiCorp's documentation,
not run, and the text does not claim otherwise:

- Every real builder: QEMU (the lab machine has no
  `/dev/kvm`), Docker (the plugin was installed live; the lab
  has no container runtime to build with), and all cloud
  builders — amazon-ebs, azure-arm, googlecompute and the rest
  (no cloud account, no credentials). Chapter 9 is theirs and
  is labelled at its head.
- Boot commands and unattended installers, disk formats and
  image registration, sysprep and Windows/WinRM builds.
- Provisioners beyond file and shell, post-processors beyond
  manifest (the checksum post-processor appears in chapter 10
  as a documented-only block), HCP Packer, and the JSON
  template format.
- The neighbour tools of chapter 11 — characterised, not run
  or benchmarked, except where this series' own guides cover
  them.
- Variable minutiae the lab did not exercise: multiple
  var-files overriding each other in order, and
  `*.auto.pkrvars.hcl` auto-loading — stated in chapter 7 as
  documentation, not as lab findings.

Fixtures are this guide's own and deliberately generic: an
invented example image called basebox, a stock banner and
settings file, a placeholder launcher script, a fictional
release history (1.0.0, 2.1.0, 3.0.0), and a lab-only SSH key
generated for the transcripts and never published.
