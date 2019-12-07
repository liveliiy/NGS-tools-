my $name = $ARGV[0];
my ($min,$max,$sum,$count) = (-1,-1,0,0);
while (<>){
	chomp;
	my @it = split /\t/,$_;
	next if ($it[2] == -1);
	$count++;
	if ($min == -1 && $max == -1){
		$min = $it[2];
		$max = $it[2];
	}elsif ($it[2] < $min){
		$min = $it[2];
	}elsif ($it[2] > $max){
		$max = $it[2];
	}
	$sum += $it[2];
}
my $ave = $sum/$count;
print "$name\nmin:$min\nmax:$max\nave:$ave\n";
