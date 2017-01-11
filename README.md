# fzf-git

A zulu plugin, providing key bindings to fuzzy match data from git repositories
using [fzf](https://github.com/junegunn/fzf). Based on [this
article](http://junegunn.kr/2016/07/fzf-git/)

## Bindings

### Files

Search through all unstaged changes (including untracked files) in the
repository, showing the highlighted files' contents in a preview window.

Bound to: `^g` `^f`

### History

Search the commit history for the current branch, showing the full commit
message for the highlighted hash in a preview window.

Bound to: `^g` `^h`

### Tags

Search all tags in the repository, showing the commit the
highlighted tag is attached to in a preview window.

Bound to: `^g` `^t`

### Branches

Search all local and remote branches, showing the highlighted branch's current
commit history in a preview window.

Bound to: `^g` `^b`

### Remotes

Search all remotes, showing the commit history for the current HEAD in a preview window.

Bound to: `^g` `^r`
