if [ -z "$_level" ]; then
	_level=3
fi

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
