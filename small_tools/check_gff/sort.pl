my $ori = $/;
$/ = "\n\n";
my %store;
while (<>){
	chomp;
	my $line = $_;
	if (/^(.*?)\t.*?gene\t(.*?)\t/){
		$store{$1}{$2} = $line;
	}
}
foreach my $scaf (sort keys %store){
	foreach my $pos (sort {$a <=> $b}keys %{$store{$scaf}}){
		print "$store{$scaf}{$pos}\n";
	}
}
	
