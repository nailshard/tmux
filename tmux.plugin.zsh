#!/usr/bin/env zsh
# Standarized $0 handling, following:
# https://z-shell.github.io/zsh-plugin-assessor/Zsh-Plugin-Standard
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

DEPENDENCES_ARCH+=( tmux )
DEPENDENCES_DEBIAN+=( tmux )

if (( $+functions[zpm] )); then
  zpm load zpm-zsh/colors zpm-zsh/helpers
fi

if [[ $PMSPEC != *f* ]] {
  fpath+=( "${0:h}/functions" )
}

autoload -Uz tmux-motd

if [[ $PMSPEC != *b* ]] {
  PATH=$PATH:"${0:h}/bin"
}

if (( $+commands[tmux] )); then
  TMUX_AUTOSTART=${TMUX_AUTOSTART:-'true'}
  TMUX_ATTACH=${TMUX_ATTACH:-'false'}

  if [[ "$TMUX_AUTOSTART" == 'true' && -z "$TMUX" ]]; then
    function _tmux_autostart() {
		[[ -f /usr/share/dict/words ]] && \
			name=$(shuf -n1  /usr/share/dict/words | tr -d -c '[:alnum:]') \
			|| name=tmux-$(date +%s)
		[[ $TMUX_ATTACH == "true" ]] && a="-A" || a=""
      cmd="tmux -2 new $a -s $name"
	  echo TERM=xterm-256color $cmd
	  bash -c "TERM=xterm-256color $cmd"
      # TERM=xterm-256color tmux new -s $(shuf -n1  /usr/share/dict/words | tr -d -c '[:alnum:]')
      exit 0
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _tmux_autostart
  fi

  if [[ $TMUX_MOTD != false && ! -z $TMUX ]]; then
    declare -a list_windows; list_windows=( ${(f)"$(command tmux list-windows)"} )
    if [[ "${#list_windows}" == 1 && "${list_windows}" == *"1 panes"*  ]]; then
      tmux-motd
    fi
  fi

fi
