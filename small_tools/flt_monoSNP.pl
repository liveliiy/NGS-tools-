while(<>){
	chomp;
	if(/^#/){
		print "$_\n";
		next;
	}
	my $line = $_;
	my @it = split(/\t/);
	my $n0=0;
	my $n1=0;
	my $n2=0;
	foreach my $i (9 .. $#it){
		if($it[$i] =~ /^0\/0\:/){
			$n0++;
		}elsif($it[$i] =~ /^1\/1\:/){
			$n2++;
		}elsif($it[$i] =~ /^0\/1\:/){
			$n1++;
		}
	}
	next if ($n0 == 0 && $n1 == 0);
	next if ($n1 == 0 && $n2 == 0);
	print "$line\n";
}
			

