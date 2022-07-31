#!/bin/bash

bdbg_check_env_level() {
	if [ ! -z "$BDBG_LEVEL" ]; then
		_level=$BDBG_LEVEL
	fi
}

bdbg_check_env_toggle() {
	if [ ! -z "$BDBG" ]; then
		if [ "$BDBG" -gt "0" ]; then
			_debug=1
		fi
	fi
}


dbg() {
	if [ "$1" -lt "$_level" ]; then
		return 0
	fi

	case "$1" in
		1)
			lvl='debug'
			clr='\e[0;96m'
			;;
		2)
			lvl='info'
			clr='\e[0;92m'
			;;

		3)
			lvl='warn'
			clr='\e[0;93m'
			;;
		4)
			lvl='error'
			clr='\e[0;91m'
			;;

	esac

	if [ -z $_debug ]; then
		return 0
	fi
	>&2 echo -e "$clr$(printf %-9s [$lvl])$2\e[0m"
}

bdbg_check_env_level
bdbg_check_env_toggle

wd=${2:-.}
if [ ! -d $wd ]; then
	>&2 echo $wd is not a directory
	exit 1
fi


t=''

d=''
p='.'
cmd=$1
if [ -z "$cmd" ]; then
	exit 1
fi

_pull=
case "$cmd" in
	init)
		t=`mktemp -d`
		;;
	update)
		pushd $2
		;;
	pull)
		pushd $2
		_pull=1
		;;
	*)
		>&2 echo invalid command: "$cmd"
		exit 1
		break
esac


repo_fetch_checkout() {
	git fetch > /dev/null 2>&1
	if [ "$?" -gt "0" ]; then
		dbg 4 "fetch heads failed in $(pwd)"
		return 1
	fi
	if [ ! -z "$_pull" ]; then
		#branch=`git branch --show-current`
		branch=`git rev-parse --abbrev-ref HEAD`
		git pull --ff-only origin $branch > /dev/null 2>&1 
	fi
}

repo_fetch_bare() {
	git fetch origin 'refs/heads/*:refs/heads/*' > /dev/null 2>&1
	if [ "$?" -gt "0" ]; then
		>&2 echo "fetch heads failed in $(pwd)"
		return 1
	fi
	git fetch origin 'refs/tags/*:refs/tags/*' > /dev/null 2>&1
	if [ "$?" -gt "0" ]; then
		>&2 echo "fetch heads failed in $(pwd)"
		return 1
	fi
}

repo_update() {
	#>&2 echo updating `pwd`
	git remote update > /dev/null 
	if [ "$?" -gt "0" ]; then
#		if [[ $remote =~ ^git ]]; then
#			...
#		fi
#		sed -e "s/^.*:\(.*\)$/\1/g"
		>&2 echo "remote update failed in $(pwd)"
		return 1
	fi
	if [ -d ".git" ]; then
		dbg 2 "updating work repo $remote -> $(pwd)"
		repo_fetch_checkout
	else
		dbg 2 "updating bare repo $remote -> $(pwd)"
		repo_fetch_bare
	fi
}

repo_init() {
	gf=`echo "$1" | grep "(fetch)" | sed -e "s/^\(.*\) .*$/\1/g"`
	mkdir -p $t/$2
	pushd $t/$2
	git init
	_IFS=$IFS
	IFS=$'\n'
	for gr in ${gf[@]}; do
		dbg 2 adding remote $gr
		echo $gr | tr "\t" " " | xargs git remote add 
	done
	IFS=$_IFS
	popd
}

p=$(realpath $p)
scan() {
	dd=$(realpath $d)
	dbg 1 "entering $dd, parent $p"
	pushd "$d" > /dev/null
	if [ "$?" -ne "0" ]; then
		p=`dirname $p`
		return
	fi
	g=`git remote -v 2> /dev/null`
	if [ "$?" -eq "0" ]; then
		if [ "$cmd" == "init" ]; then
			repo_init "$g" "$p"
		elif [ "$cmd" == "update" ]; then
			repo_update $p
		elif [ "$cmd" == "pull" ]; then
			repo_update $p
		fi
	else
		for d in `find . -maxdepth 1 -not -path "\." -type d -printf "%f\n"`; do
			#echo scan $d
			p="$p/$d"
			scan 
		done
	fi
	popd > /dev/null
	p=`dirname $p`
	#echo exiting, parent now $p
}

pushd $wd
d='.'
scan 

if [ "$cmd" == "update" ]; then
	popd
fi
#update() {
#	pushd $wd
#	for d in ${ds[@]}; do
#		pushd $d
#		for sd in `find . -maxdepth 1 -type d`; do
#			pushd $sd
#			g=`git remote -v show 2> /dev/null`
#			go=`git remote -v show 2> /dev/null | grep -e "^origin"`
#			if [ "$?" -gt "0" ]; then
#				>&2 echo no git in $sd
#			else
#				u=`echo $g | grep "(fetch)" | awk '{print $2}'`
#				uo=`echo $go | grep "(fetch)" | awk '{print $2}'`
#				>&2 echo found git $u
#				b='basename $sd'
#				echo $u > $t/$sd
#				git remote update
#				git fetch
#			fi
#			popd
#		done
#		popd
#	done
#	popd
#}
