use warnings;
use strict;
my $gff = $ARGV[0];

open GFF,$gff or die "$!\n";
my %ref;
while (<GFF>){
	next if (/^#/);
	chomp;
	my @it = split /\t/,$_;
	if ($it[2] eq "gene"){
		$it[8] =~ /Name=(\S+)/;
		my $id = $1;
		$ref{$it[0]}{$it[3]}{$it[4]} = $id;
	}
}
close GFF;
print STDERR "processed GFF3 file $gff\n";

my @longgene;
foreach my $scaf (sort keys %ref){
	my $exs = 0;
	my $exf = 0;
	my $exname = "";
	foreach my $start (sort {$a <=> $b}keys %{$ref{$scaf}}){
		my @gabbage = (keys %{$ref{$scaf}{$start}});
		my $end = $gabbage[0];
		if ($exf == 0){
			$exs = $start;
			$exf = $end;
			$exname = $ref{$scaf}{$start}{$end};
			push @longgene,$exname;
		}elsif ($start < $exf && $end > $exs){
			my $cuname = $ref{$scaf}{$start}{$end}; 
			print STDERR "find a pair of repeat gene $exname\t$cuname\n";
			my $culength = $end - $start + 1;
			my $exlength = $exf - $exs + 1;
			if ($culength > $exlength){
				pop @longgene;
				$exs = $start;
				$exf = $end;
				$exname = $ref{$scaf}{$start}{$end};
				push @longgene,$exname;
			}
		}else{
			$exs = $start;
			$exf = $end;
			$exname = $ref{$scaf}{$start}{$end};
			push @longgene,$exname;
		}
	}
}
foreach my $kk (@longgene){
	print "$kk\n";
}
