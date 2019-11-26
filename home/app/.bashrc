# useful aliases
alias ll='ls -la'
alias artisan="php artisan"

# prompt colors and short user display
force_color_prompt=yes
PS1='\[\033[1;36m\]\u\[\033[1;31m\]\[\033[1;32m\]:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '

# artisan autocompletion
_artisan()
{
	COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
	COMMANDS=`artisan --raw --no-ansi list | sed "s/[[:space:]].*//g"`
	COMPREPLY=(`compgen -W "$COMMANDS" -- "${COMP_WORDS[COMP_CWORD]}"`)
	return 0
}

complete -F _artisan artisan

# for customization
FILE=/home/app/.custom_bashrc
if [ -f "$FILE" ]; then
    source "$FILE"
fi
