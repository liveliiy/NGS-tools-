while (<>){
	chomp;
	next if (/^\d/);
	my @it = split /\s+/,$_;
	print ">$it[0]\n$it[1]\n";
}
