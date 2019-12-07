for ((i=1;i<=16;i++));
do
perl get_Dxy.v2.pl jai_chr$i jmad_chr$i 10000 2000 0 1 1>AM_Dxy_type2_chr$i.out 2>AM_Dxy_type2_chr$i.log &
done
