# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
    IFS=''
    local declare files=($(fzf-tmux --query="$1" --select-1 --exit-0))
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
    unset IFS
}

# fd - cd to selected directory
fd() {
    local dir
    dir=$(find ${1:-*} -path '*/\.*' -prune \
        -o -type d -print 2> /dev/null | fzf-tmux +m) &&
        cd "$dir"
}

# fda - including hidden directories
fda() {
    local dir
    dir=$(find ${1:-.} -type d 2> /dev/null | fzf-tmux +m) && cd "$dir"
}


# fu - cd upward
fu() {
    print_parent_dirs() {
        path=$(pwd)
        path=${path%/*}
        while [[ "$path" != "" ]]; do
            echo $path
            path=${path%/*}
        done
        echo "/"
    }
    local DIR=$(print_parent_dirs | fzf-tmux)
    cd "$DIR"
}

# flog - git commit browser
flog() {
  glol |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --header "Press CTRL-S to toggle sort" \
      --preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                 xargs -I % sh -c 'git show --color=always % | head -$LINES'" \
      --bind "enter:execute:echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
              xargs -I % sh -c 'vim fugitive://\$(git rev-parse --show-toplevel)/.git//% < /dev/tty'"
}

# v - open files in ~/.viminfo
unalias v 2>/dev/null
v() {
    local files
    files=$(grep '^>' ~/.viminfo | cut -c3- |
    while read line; do
        [ -f "${line/\~/$HOME}" ] && echo "$line"
    done | fzf-tmux -d -m -q "$*" -1) && vim ${files//\~/$HOME}
}
alias fv=v

_vless="vim -u ~/dotfiles/vim/less.vim"

fz() {
    local dir
    dir="$(fasd -Rdl "$1" | fzf-tmux -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}

fag() {
    ag --color $@ | fzf --ansi --reverse --no-sort \
        --bind "ctrl-m:execute:
                (grep -o '[^: ]\+:\d\+' | head -1 | sed 's/^.//g' |
                awk -F':' '{print \"+\"\$2\" \"\$1}' |
                xargs -I % sh -c '</dev/tty $_vless %') << 'FZF-EOF'
                {} FZF-EOF"
}

vless() {
    if test $# -eq 0; then
        $_vless -
    else
        $_vless $@
    fi
}