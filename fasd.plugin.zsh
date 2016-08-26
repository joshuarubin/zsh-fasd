#
# Maintains a frequently used file and directory list for fast access.
#
# Authors:
#   Wei Dai <x@wei23.net>
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Return if requirements are not found.
if (( ! $+commands[fasd] )); then
  return 1
fi

#
# Initialization
#

cache_file="${0:h}/cache.zsh"
if [[ "${commands[fasd]}" -nt "$cache_file" || ! -s "$cache_file"  ]]; then
  # Set the base init arguments.
  init_args=(zsh-hook)

  # Set fasd completion init arguments
  init_args+=(zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install posix-alias)

  # Cache init code.
  fasd --init "$init_args[@]" >! "$cache_file" 2> /dev/null
fi

source "$cache_file"

unset cache_file init_args

#
# Aliases
#

if (( $+commands[fzf] )); then
  fasd_i() {
    fasd -l "$@" | fzf --tac --no-sort
  }

  fasd_i_cd() {
    local _fasd_all=$(fasd -ld "$@" | head -n 2)
    [ -z "$_fasd_all" ] && return
    if [ "$(echo "$_fasd_all" | wc -l)" -eq 1 ]; then
      cd "$_fasd_all"
      return
    fi
    local _fasd_ret="$(fasd -ld "$@" | fzf --tac --no-sort)"
    [ -d "$_fasd_ret" ] && cd "$_fasd_ret" || printf %s\n "$_fasd_ret"
  }

  alias s='fasd_i'
  alias sd='fasd_i -d'
  alias sf='fasd_i -f'
  alias zz='fasd_i_cd'

  alias j='fasd_i_cd'
else
  alias j="fasd_cd -d -i"
fi
