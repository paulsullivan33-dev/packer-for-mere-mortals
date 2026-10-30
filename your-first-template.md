# Your First Template

**By the end of this chapter you can read
the lab's template end to end, format a
template the official way, prove one
valid without building anything, and
install an external plugin.** The checks
are the four commands themselves:
`packer fmt -check` exits 0, `packer
validate` says the configuration is
valid, `packer inspect` lists the build,
and `packer plugins installed` names a
plugin that was not there before.

The template is `packer-lab/image.pkr.hcl`.
Read it now, slowly. It declares six
variables (chapter 7), one source — the
**null builder**, logged in by SSH to
127.0.0.1 — and one build that uploads a
folder of files, runs six shell lines,
downloads one file back, and writes a
manifest. Nothing in it needs a cloud, a
hypervisor, or a plugin download, and
chapter 5 runs it exactly as it stands.

## fmt: one true layout

HCL is forgiving about spacing, which
means every author spaces differently.
`packer fmt` rewrites a template in the
canonical layout — aligned `=` signs,
standard indentation — so templates in a
team all read the same. It is a checker
as well as a fixer. The lab kept a
deliberately scruffy copy,
`packer-lab/unformatted.pkr.hcl`, and ran
(transcript `t03`):

```bash
packer fmt -check -diff unformatted.pkr.hcl   # exit 3, shows the diff
packer fmt unformatted.pkr.hcl               # rewrites it in place
packer fmt -check unformatted.pkr.hcl        # exit 0, silent
```

Exit code 3 from `-check` is the part
worth remembering: scripts and CI can
fail a build on an unformatted template
without changing a byte.

## validate: catch the typo before the build

`packer validate image.pkr.hcl` parses
the template, resolves its references,
and checks them — without starting any
machine:

```text
The configuration is valid.
```

What that buys you is best seen in the
failure the lab arranged on purpose.
`packer-lab/broken.pkr.hcl` is the same
template with one reference mistyped —
`var.releas` instead of `var.release`.
Validate catches it in well under a
second, names the line, and exits 1
(transcript `t08`):

```text
Error: Failed preparing provisioner-block "shell" ""

  on broken.pkr.hcl line 57:
  (source code not available)

broken.pkr.hcl:60,21-28: Unsupported attribute; This object does not have an
attribute named "releas".
```

A build would have taken longer to say
less. Run validate every time; it is the
cheapest check in this guide.

## inspect: the template, summarised

`packer inspect` prints what Packer
understood: every variable with its
current value, every build, its
provisioners in order, and its
post-processors (transcript `t04`). It is
the fastest way to answer "what will this
actually do?" before a build — and, in
chapter 7, to watch a variable's value
change as different sources supply it.

## init: where plugins come from

Builders that are not bundled are
declared in a `packer` block and
downloaded by `packer init`. The lab's
main template needs none — but asking
for one teaches the mechanism, including
its sharpest edge. The first init attempt
asked for the null builder as if it were
a plugin (transcript `t02`):

```text
Failed getting the "github.com/hashicorp/null" plugin:
1 error occurred:
	* GET https://api.github.com/repos/hashicorp/packer-plugin-null/git/matching-refs/tags: 404 Not Found []
```

A 404 here does not mean the network is
down. It means **there is no such plugin
to fetch**: the null builder ships inside
Packer, and `github.com/hashicorp/null`
has no plugin repository behind it. When
init 404s, the first question to ask is
whether the thing you named is bundled —
or whether the source address is
mistyped.

A plugin that genuinely is external
installs without fuss. `packer-lab/init-demo.pkr.hcl`
declares only the Docker plugin, and:

```bash
packer init init-demo.pkr.hcl
packer plugins installed
```

prints the install line and then the path
of `packer-plugin-docker_v1.1.4` under
`~/.config/packer/plugins/` (transcript
`t02`). The Docker *builder* is
documented-only in this guide — the lab
has no container runtime — but its plugin
install is real, and every cloud
builder's plugin arrives by exactly this
route.
