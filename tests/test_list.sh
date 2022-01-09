wd=$(pwd)

if [ ! -f ./gitrefresh.sh ]; then
	>&2 echo please run from code repository root
	exit 1;
fi

ts=$(mktemp -d)
td=$(mktemp -d)
r=$(mktemp)
pushd $ts

ds=(a b c)
for d in ${ds[@]}; do
	mkdir -v $d
	pushd $d
	git init
	uuidgen > data.txt
	git add data.txt
	git commit -m "initial commit"
	popd
	pushd $td
	repo="file://$ts/$d"
	echo $repo >> $r
	git clone $repo
	popd
done
popd

vr=$(mktemp)
vl=$(mktemp)
sort $r > $vr

bash ./gitlist.sh $td | sort > $vl

diff $vr $vl
