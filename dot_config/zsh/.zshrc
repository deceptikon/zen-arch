#!/usr/bin/env zsh

# 0) prompt machinery
setopt prompt_subst
autoload -U colors && colors

# 1) git helpers used by theme + plugin
source "$ZDOTDIR/gitinit"

# 2) git aliases/wrappers (needs compdef only if you keep those lines;
#    safest: load after a early-minimal compinit OR after full compinit)
#    Option A below uses full setup at the end → source plugin after it
#    OR source plugin here and accept re-compinit cost.

# 3) theme (needs git_prompt_info / colors / prompt_subst)
source "$ZDOTDIR/themes/arrow.zsh-theme"

# 4) env
[[ -f "$ZDOTDIR/envs" ]] && source "$ZDOTDIR/envs"

# 5) plugin manager
source /usr/share/zsh-antidote/antidote.zsh
antidote load "$ZDOTDIR/plugins" "$ZDOTDIR/plugins.zsh"

# 6) YOUR aliases last (win over plugin aliases)
[[ -f "$ZDOTDIR/aliases" ]] && source "$ZDOTDIR/aliases"

# 7) history
HISTFILE="$ZDOTDIR/history"
HISTSIZE=10000
SAVEHIST=10000
HISTDUP=erase
setopt APPEND_HISTORY

# 8) completion once, then git plugin (so its compdef lines work)
autoload -Uz compinit
compinit
source "$ZDOTDIR/git.plugin.zsh"

# 9) UI / options / keys that depend on plugins (autosuggest, fzf-tab, …)
setopt globdots AUTO_CD AUTO_LIST AUTO_MENU MENU_COMPLETE
zstyle ':completion:*' menu select
zstyle ':completion:*' select-prompt '%SScrolling: current selection at %p%s'
bindkey '^ ' autosuggest-accept
bindkey "^R" history-incremental-search-backward
