#!/user/bin/perl -w
use strict;
use warnings;


open IN,$ARGV[0] or die;

my (%ratio_sfs,%unfolded_sfs);###make folded and unfolded SFS
####################################################################################################################################################################################################################################
my $sample_n=0;
while (<IN>){
	my $line = $_;
	chomp $line;
	next if ($line =~ /^#/);
	my @array = split /\t/,$line;
	$sample_n = $#array-8;
	my ($dlens,$het) = (0,0);
	$dlens = $sample_n * 2;
	foreach my $i (9 .. $#array){
		if ($array[$i] =~ /(.*?):(.*?):(\d+):/){
			my ($gtype,$ad,$dp) = ($1,$2,$3);
			next if ($gtype eq '0/0');
			$het++ if ($gtype eq '0/1');
			$het = $het + 2 if ($gtype eq '1/1');
		}
	}
	$unfolded_sfs{$het}++;
	if ($het <= $sample_n){
		$ratio_sfs{$het}++;
	}else{
		my $tmp = $dlens - $het;
		$ratio_sfs{$tmp}++;
	}
}
close IN;
#####calculate SFS#################################################################################################################################################################################################
print "foldedSFS:\n";
my $sfssum = 0;
foreach my $k (0 .. $sample_n){
	if (exists $ratio_sfs{$k}){
		print "  $ratio_sfs{$k}";
		$sfssum = $sfssum + $ratio_sfs{$k};
	}else{
		print "  0";
	}
}
print "\n";
print STDERR "snp number:$sfssum\n";
print "unfoldedSFS: (not exact anyway)\n";
foreach my $sfs (0 .. $sample_n*2){
	if (exists $unfolded_sfs{$sfs}){
		print "$sfs\t$unfolded_sfs{$sfs}\n";
	}else{
		print "$sfs\t0\n";
	}
}
#####END############################################################################################################################################################################################################################
