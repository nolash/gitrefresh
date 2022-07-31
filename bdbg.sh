# This script normally lives in https://git.defalsify.org/bashbdbg
# Licenced under Do What The Fuck You Want Licence v2
# (c) 2021-2022 by lash 

bdbg_check_env_level() {
	if [ -z "$BDBG_LEVEL" ]; then
		_level=3
	else
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

bdbg() {
	if [ -z "$_level" ]; then
		bdbg_check_env_level
	fi

	if [ -z "$_debug" ]; then
		bdbg_check_env_toggle
	fi
}
