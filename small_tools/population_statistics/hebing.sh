prefix=$1
for((i=1;i<=16;i++));
do
cat $prefix\_chr$i\.out >>$prefix.txt
done
