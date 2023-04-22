if [ ! -z $1 ]; then
	pushd $1
fi

if [ -z "$GITREFRESH_CHECKOUT" ]; then
	gitargs='--mirror'
fi

while IFS= read -r repo; do
	read -ra parts <<< "$repo"
	url=${parts[0]}
	if [ -z ${parts[1]} ]; then
		basename_raw=$(basename $repo)
		basename_chomped=${basename_raw%.git}
		>&2 echo "checkout repo $basename_chomped ($repo)"
		basename_git=${basename_chomped}.git
	else
		basename_git=${parts[1]}
	fi
	if [ -e $basename_git ]; then
		>&2 echo "folder $basename_git already exists, skipping"
		continue
	fi
	echo "clone $url $gitargs to $basename_git"
	git clone $gitargs $url $basename_git
done

if [ ! -z $1 ]; then
	popd
fi
