. tests/test_list.sh

hl=$(mktemp)

pushd $ts
for d in ${ds[@]}; do
	pushd $d
	uuidgen > data.txt	
	git commit -a -m "more commit"
	git rev-parse HEAD >> $hl
	popd
done
popd

bash ./gitrefresh.sh update $td

hr=$(mktemp)
pushd $td
for d in ${ds[@]}; do
	pushd $d
	git remote update
	git pull --ff-only
	git rev-parse HEAD >> $hr
	popd
done
popd

diff $hl $hr
