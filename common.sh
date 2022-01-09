chomp_git_path() {
	basename_raw=$(basename $1)
	basename_chomped=${basename_raw%.git}
	>&2 echo "checkout repo $basename_chomped ($1)"
	basename_git=${basename_chomped}.git
	echo -n $basename_git > $2	
}
