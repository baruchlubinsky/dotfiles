_src() {
	local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    dir1=`ls "$HOME/development/"`
    dir2=`ls "$GOPATH/src/code.hyraxbio.co.za/"`
    opts=`echo $dir1 $dir2`
    #opts=( $(echo `ls "$HOME/development/"` `ls "$GOPATH/src/code.hyraxbio.co.za/"`) )

    COMPREPLY=( $(compgen -W "${opts}" ${cur}) )
    return 0
}

src() {
	if [ -d "$HOME/development/$1" ]; then
		cd $HOME/development/$1
	elif [ -d "$GOPATH/src/code.hyraxbio.co.za/$1" ]; then
		cd $GOPATH/src/code.hyraxbio.co.za/$1
	else
		cd $HOME/development
	fi
	if [ -f .env.sh ]; then
		source .env.sh
	fi
}

complete -F _src src