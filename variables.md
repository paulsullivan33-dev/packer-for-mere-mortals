# Variables

**By the end of this chapter you can give
the same template different values four
different ways, and say which source wins
when several speak at once.** The check
is not an assertion: the finished
artifacts in transcript `t07` carry three
different release numbers, each traceable
to the source that supplied it.

A variable is declared once, with a type
and a default:

```hcl
variable "release" {
  type    = string
  default = "1.0.0"
}
```

and used anywhere as `var.release` — in
the lab's template it flows into the
shell provisioner's environment, and from
there into the staged `build-info.txt`
and the manifest's custom data. That
makes the artifact itself the scoreboard:
whatever value won is written inside the
build's output, where you can read it
afterwards.

## The four sources

**The default.** Build with nothing
extra and the declared default applies.
The first build (transcript `t06`) staged
`release=1.0.0`, because the template
says so.

**A variable file.** `release.pkrvars.hcl`
in the lab folder sets two values:

```hcl
release      = "2.1.0"
motd_message = "basebox release build. Authorised users only."
```

```bash
packer build -var-file=release.pkrvars.hcl -var stage_dir=packer-stage-2.1 image.pkr.hcl
```

The staged tree says `release=2.1.0`, and
its `etc/motd` carries the file's message
(transcript `t07`). One file per flavour
of build — release, test, per-customer —
is the normal way teams use this. (The
`-var stage_dir=…` alongside it keeps each
build in its own fresh folder, per
chapter 6's rule.)

**The environment.** Any variable can be
set as `PKR_VAR_<name>`:

```bash
PKR_VAR_release=9.9.9 packer inspect image.pkr.hcl
```

`inspect` reports `var.release: "9.9.9"` —
the environment's value, not the default
(transcript `t07`). This is the route CI
systems use, where values arrive from the
job's configuration rather than from
files.

**The command line.** `-var name=value`
speaks last and loudest:

```bash
packer build -var-file=release.pkrvars.hcl -var release=3.0.0 -var stage_dir=packer-stage-3.0 image.pkr.hcl
```

The var-file said 2.1.0. The staged
`build-info.txt` says **3.0.0**
(transcript `t07`). The command line
overrode the file — proved in the
artifact, not in a manual's precedence
table.

## The order, as the lab found it

From weakest to strongest: the declared
**default**; a **variable file**; the
**environment**; the **command line**.
(Two finer points the lab did not need
and did not test: with several var-files,
later ones override earlier ones, and
`*.auto.pkrvars.hcl` files are loaded
without being named. HashiCorp's
documentation covers both.) One
practical moral: because the winner is
not visible in the template, a build you
cannot explain is usually a variable you
forgot you set. `packer inspect` under
the same conditions as the build shows
the values Packer will actually use —
run it before blaming the template.
