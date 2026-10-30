# Troubleshooting

Every problem in this chapter happened in
this guide's lab, in this order, unless it
says otherwise. The transcripts named are
the receipts.

## `packer init` answers 404 for a plugin

```text
Failed getting the "github.com/hashicorp/null" plugin:
	* GET https://api.github.com/repos/hashicorp/packer-plugin-null/git/matching-refs/tags: 404 Not Found []
```

(Transcript `t02`.) Two causes look alike.
If the plugin exists — the Docker plugin
installed in the same transcript proves
the route works — a 404 means the thing
you named has no plugin repository,
usually because it is **bundled inside
Packer** (the null builder is) or because
the source address is mistyped. Do not
retry the network. Check whether the
builder works with no `required_plugins`
block at all.

## validate names an attribute that "does not exist"

```text
broken.pkr.hcl:60,21-28: Unsupported attribute; This object does not have an
attribute named "releas".
```

(Transcript `t08`.) This is `packer
validate` doing exactly its job: a
variable reference with a typo. The line
and column point at the reference, not
the declaration. The fix is the spelling;
the lesson is to run validate before
every build, because a build takes
longer to tell you the same thing.

## validate complains about the SSH key file

`ssh_private_key_file is invalid: stat
./id_lab: no such file or directory` —
validate checks that the key file exists,
resolving `${path.root}` against the
template's folder. Generate the key
beside the template (transcript `t01`),
or correct the path. A template moved
without its key fails here first, which
is validate being helpful again.

## The build connects, uploads — and a shell step cannot find its file

```text
==> basebox.null.base: chmod: cannot access 'packer-stage/opt/app/start.sh': No such file or directory
==> basebox.null.base: Provisioning step had errors
```

(Transcript `t05`.) The upload happened;
the layout did not match the template's
assumption. Read chapter 6's rules, then
look — do not guess: list the destination
on the target and compare it with what
the next step expects. In the lab the
payload's folder levels had been poured
away, and one `rootfs` folder carrying
the intended layout fixed it.

## The second build's tree has a nested copy of the first

`packer-stage/rootfs/…` sitting beside
`packer-stage/etc/…` (transcript `t09`)
means two builds shared a destination.
Nothing was overwritten; the second
upload nested into the first build's
folder. Delete the stage folder (or give
the build a fresh `stage_dir`) and
rebuild. Packer never cleans a target for
you.

## The receipt disagrees with the artifact

`collected/build-info.txt` says release
3.0.0 while the original stage folder
says 1.0.0. Both are telling the truth —
about different builds. The manifest and
any fixed download path hold the **most
recent** build only (chapter 8). Compare
files from the same run, and archive
receipts per build if you need history.

## sshd refuses to start over `/run/sshd`

`"/run/sshd must be owned by root and not
group or world-writable"` (transcript
`t01`). In the sandbox the directory
existed with mode 770; `chmod 755
/run/sshd` fixed it. On a normal machine
this does not arise — the packaged sshd
maintains its own runtime directory —
but in containers and minimal images it
is the first thing to check when a
hand-run sshd will not start.

## The build waits forever for SSH

"Waiting for SSH to become available…"
that never ends is a connection that
never succeeds: wrong port, wrong key,
the server listening somewhere else, or —
in the null builder's case — the target
being a machine whose SSH you have not
proved by hand. Prove the door first:
`ssh -i <key> -p <port> <user>@<host>`
from your own terminal (chapter 5). If
the hand login fails, Packer cannot fix
it; if it succeeds, the difference is in
the source block.
