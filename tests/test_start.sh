. tests/test_list.sh

tn=$(mktemp -d)

>&2 echo "bootstrap on $tn"

cat $vl | bash ./gitstart.sh $tn

vn=$(mktemp)
bash ./gitlist.sh $td | sort > $vn
diff $vr $vn

fns=(a.git b.git c.git)
for f in ${fns[@]}; do
	echo checking $tn/$f
	if [ ! -d $tn/$f ]; then
		exit 1;
	fi
done
