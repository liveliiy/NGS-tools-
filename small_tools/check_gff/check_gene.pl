my $numgene = 0;
while (<>){
	chomp;
	my @it = split /\t/,$_;
	if ($it[2] eq "gene"){
		$numgene++;
	}
}
print "$numgene\n";
