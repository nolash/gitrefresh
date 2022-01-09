if [ ! -z $1 ]; then
	pushd $1
fi

while IFS= read -r repo; do
	basename_raw=$(basename $repo)
	basename_chomped=${basename_raw%.git}
	>&2 echo "checkout repo $basename_chomped ($repo)"
	basename_git=${basename_chomped}.git
	if [ -e $basename_git ]; then
		>&2 echo "folder $basename_git already exists, skipping"
		continue
	fi
	git clone $repo $basename_git
done

if [ ! -z $1 ]; then
	popd
fi
