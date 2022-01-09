while test $# != 0; do
	case "$1" in
		-v)
			_debug=1
			_level=1
			shift
			;;
		-d)
			shift
			description=$1
			shift
			;;
		-o)
			shift
			owner=$1
			shift
			;;
		*)
			break
			;;
	esac
done

. bdbg.sh

p=$1
if [ -z $1 ]; then
	dbg 4 "missing remote repo"
	exit 1
fi

. common.sh

if [ ! -z $description ]; then
	dbg 2 "using git repo description: $description"
fi

if [ ! -z $owner ]; then
	dbg 2 "using git repo owner: $owner"
fi

b=${GIT_BASE:-.}
set +e

t=$(mktemp)
chomp_git_path $p $t
read -r pc < $t
dbg 2 "using git repo path: $b/$pc for $p"

pushd $b
git clone --bare $p $pc
popd

if [ ! -z $description ]; then
	echo -n $description > $pc/description
fi

if [ ! -z $owner ]; then
	grep -e "^[owner]" $pc/config
	if [ $? -eq "0" ]; then
		>&2 echo "owner already set in config, skip, edit manually if you really want"
	else
		cat <<EOF >> $pc/config
[gitweb]
	owner = $owner
EOF
	fi
fi

set -e
