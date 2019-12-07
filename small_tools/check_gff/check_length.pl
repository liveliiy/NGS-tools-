my ($list,$lengthfile) = @ARGV;
open LI,$list or die "Can't find my list file$!\n";
my @chrlist;
while (<LI>){
	chomp;
	push @chrlist,$_;
}
close LI;
open LEN,$lengthfile or die "Can't find my length file $!\n";
my $fastalen = 0;
my $gfflen = 0;
while (<LEN>){
	chomp;
	next if (/^ID/);
	my @it = split /\t/,$_;
	$it[0] =~ s/>//;
	$fastalen += $it[1];
	if ($it[0] ~~ @chrlist){
		$gfflen += $it[1];
	}
}
my $ratio = $gfflen/$fastalen;
print "gff:$gfflen\nfasta:$fastalen\nratio:$ratio\n";
