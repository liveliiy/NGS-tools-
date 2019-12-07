my @chr;
while (<>){
	chomp;
	next if (/^$/);
	my @it = split /\t/,$_;
	unless ($it[0] ~~ @chr){
		push @chr,$it[0];
	}
}
foreach my $kk (sort @chr){
	print "$kk\n";
}
