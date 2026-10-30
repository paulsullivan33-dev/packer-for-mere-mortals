# Glossary

**Artifact** — whatever a build produces.
With a real builder, the registered
image; with the null builder, nothing
exported, and the staged files stand in
for it.

**Base image** — the clean starting image
a cloud builder launches before
provisioning begins. The ISO plays the
same role for QEMU.

**Builder** — the plugin code behind a
source type: it starts the machine,
connects, and saves the result as an
image. QEMU, Docker, `amazon-ebs` and
`null` are builders.

**Bundled plugin** — a plugin that ships
inside the Packer binary itself and
needs no download. The null builder,
file and shell provisioners and the
manifest post-processor are bundled.

**Communicator** — the connection
provisioners travel over: SSH on Linux,
WinRM on Windows.

**Golden image** — the approved, frozen
image from which identical machines are
launched, built from a template rather
than assembled by hand.

**HCL** — HashiCorp Configuration
Language, the language templates are
written in: labelled blocks,
`name = value` settings, `var.` references.

**Image** — a saved, launchable copy of a
whole machine's disk and configuration.

**Manifest** — the JSON receipt the
manifest post-processor writes after a
build: builder, time, artifact identity,
and any custom data the template adds.

**Null builder** — the bundled builder
that starts nothing and provisions a
machine it reaches by SSH. This guide's
lab.

**Plugin** — a separate program Packer
downloads (with `packer init`) or finds
bundled, providing a builder, provisioner
or post-processor.

**Post-processor** — a step that works on
the finished artifact: manifest,
checksum, compression, upload.

**Provisioner** — one setup step inside a
build, run in order over the
communicator: file copies, shell
commands, and more.

**Source block** — the template block
naming one builder and its settings,
such as `source "null" "base"`.

**Stage directory** — this guide's term
for the folder the lab's build fills on
the target, standing in for the image's
filesystem.

**Template** — the `.pkr.hcl` file that
describes a build: variables, sources,
provisioners, post-processors.

**Variable** — a named template value
with a default, settable by file
(`-var-file`), by environment
(`PKR_VAR_<name>`), or by flag (`-var`) —
in increasing order of strength.
