#!/bin/bash

_level=3
while test $# != 0; do
	case "$1" in
		-v)
			_debug=1
			shift
			_level=$1
			shift
			;;
		-n)
			_no_remotes=1
			shift
			;;
		-u)
			_update=1
			_no_remotes=1
			shift
			;;
		-p)
			_path=1
			shift
			;;
		-pp)
			_fullpath=1
			_path=1
			shift
			;;

		*)
			break
			;;
	esac
done

dbg() {
	if [ "$1" -lt "$_level" ]; then
		return 0
	fi

	case "$1" in
		1)
			lvl='debug'
			clr='\e[0;36m'
			;;
		2)
			lvl='info'
			clr='\e[0;32m'
			;;

		3)
			lvl='warn'
			clr='\e[0;33m'
			;;
		4)
			lvl='error'
			clr='\e[0;31m'
			;;

	esac

	if [ -z $_debug ]; then
		return 0
	fi
	>&2 echo -e "$clr$(printf %-9s [$lvl])$2\e[0m"
}

git_at_to_https() {
	url=$1
	if [ ${1:0:4} == 'git@' ]; then
		url_right=`echo ${1:4} | sed -e 's/:/\//'`
		url="https://${url_right}"
	fi
	echo $url
}

wd=${1:-`pwd`}
wd=$(realpath $wd)

dbg 1 "root dir $wd"

_IFS=$IFS
IFS=$(echo -en "\n\b")
used=''
pushd "$wd" > /dev/null
#for d in $(find ~- -type d -not -name ".git"); do
for d in $(find . -type d -not -name ".git"); do
	if [ ! -z $used ]; then
		if [[ "$d" =~ ^$used ]]; then
			dbg 1 "still in repo, skipping $d"
			continue
		else
			used=''
		fi
	fi
	pushd "$d" > /dev/null
	if [ $(git rev-parse HEAD 2> /dev/null) ]; then
		used=$d
		dbg 2 "found repo $d"
		if [ ! -z $_update ]; then
			git remote update
			continue
		fi
		if [ ! -z $_no_remotes ]; then
			echo $d
			continue
		fi

		origin=`git remote -v | awk '$1 ~ /origin/ && $3 == "(fetch)" { print $2; }'`
		if [[ $origin =~ ^ssh ]]; then
			dbg 4 "skipping ssh url $origin"
			popd > /dev/null
			continue
		elif [ -z "$origin" ]; then
			dbg 4 "origin missing from repo $d"
			dbg 4 "available remotes $(git remote -v)"
			popd > /dev/null
			continue
		fi
		t=$origin
		origin=$(git_at_to_https $origin)
		if [ "$t" != "$origin" ]; then
			dbg 3 "changed $t -> $origin"
		fi
		if [ ! -z $_path ]; then
			if [ -z $_fullpath ]; then
				p=${d/$wd}
			else
				p=$wd/${d:2}
			fi

			echo -e "$origin\t$p"
		else
			echo "$origin"
		fi
	fi	
	popd > /dev/null
done
popd > /dev/null
