#!/bin/bash

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
#echo using repo dir $(realpath $t)

repo_update() {
	#>&2 echo updating `pwd`
	git remote update > /dev/null
#	if [ "$?" == "0" ]; then
#		if [[ $remote =~ ^git ]]; then
#			...
#		fi
#		sed -e "s/^.*:\(.*\)$/\1/g"
#	fi
	git fetch > /dev/null
	if [ ! -z "$_pull" ]; then
		#branch=`git branch --show-current`
		branch=`git rev-parse --abbrev-ref HEAD`
		git pull --ff-only origin $branch > /dev/null
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
		echo adding remote $gr
		echo $gr | tr "\t" " " | xargs git remote add 
	done
	IFS=$_IFS
	popd
}

scan() {
	echo entering $d parent $p
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
	echo exiting, parent now $p
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
