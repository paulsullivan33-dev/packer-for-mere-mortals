# Limits

An honest account of what Packer does not
do, including the limits this guide's own
lab ran into. None of these are reasons
to avoid the tool; all of them are
cheaper to know now than at the end of a
build.

**Packer makes images. It does not run
anything.** It will not deploy the image,
scale it, heal it, or notice when a
machine built from it is changed by hand.
The moment a build finishes, Packer's
knowledge of the world ends. Plan the
other half of the pipeline — Terraform,
a cloud console, a hypervisor's tooling —
yourself.

**A build is only as reproducible as its
inputs.** The same template a month apart
can produce different images, because the
template is not the only input: the base
image's publisher may have updated it,
the package archive has certainly moved,
and an install step that says "the
latest" means whatever latest is that
day. Pin versions where it matters —
base images by checksum, packages by
version — or accept that "golden" means
"golden-shaped".

**Provisioner failures strand invisible
machines.** With a real builder, a failed
build leaves a stopped instance or a
half-built VM behind, and Packer's
cleanup depends on the builder and the
failure. The lab's lab had nothing to
strand — a folder is easy to delete — but
cloud builds deserve a look at the bill
and the console after a failure, not just
a re-run.

**The file provisioner's layout is its
own.** Chapter 6's rules are real and
were learned by failure: folders are
poured, top-level files in a source
folder are not carried, and rebuilds
nest instead of replacing. None of that
is guessable from the block's friendly
shape. Test uploads on a small tree —
the lab's probe tree had four files —
before trusting a large one.

**Passwords and secrets do not belong in
templates.** Templates are code; they get
committed and shared. Credentials for
builders come from the environment;
secrets a provisioner needs come from
variables marked sensitive and supplied
per build — and even then, anything a
provisioner writes into the image is in
the image, readable by everyone who can
launch it. Bake in no secret you would
not hand to every future user of the
image.

**Windows and desktops are second
citizens in this guide.** The communicator
story, the provisioners and chapter 8's
checks were all proved on Linux over SSH.
Packer builds Windows images too, over
WinRM, with its own base-image and
sysprep story — none of which this
guide's lab could run, so none of it is
taught here.

**The null builder proves templates, not
images.** It is this guide's foundation
and it is a rehearsal: it validates the
template, the provisioners and the
variable flow, but the boot behaviour,
disk layout and cloud registration of a
real image are exactly the parts it
leaves out. Chapter 9's builders close
that gap; only experience on one of them
proves a real image boots.
