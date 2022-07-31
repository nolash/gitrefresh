. tests/test_list.sh

bash ./gitrefresh.sh update $td

>&2 echo have td=$td ts=$rs r=$r from source

pushd $ts

d="d"
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

hl=$(mktemp)
hr=$(mktemp)
pushd a
uuidgen > data.txt	
git commit -a -m "more commit"
git rev-parse HEAD >> $hl
git rev-parse HEAD >> $hr
popd

popd

vr=$(mktemp)
vl=$(mktemp)
sort $r > $vr

bash ./gitlist.sh $td | sort > $vl
diff $vr $vl

bash ./gitrefresh.sh update $td
diff $hl $hr
