#!/usr/bin/perl -w
use warnings;
use strict;
my $lens;#$ed-$st+1;
my $dlens;#$lens*2
my %sfs;
while(<>){
	chomp;
	next if(/^##/);
	if(/^#/){
		my @head = split(/\t/);
		$lens = $#head - 8;
		$dlens = $lens * 2;
		next;
	}
	my $line = $_;
	my @it = split(/\t/);
	my $het = 0;
	foreach my $k (9 .. $#it){
		if($it[$k] =~ /0\/0/){
			next;
		}elsif($it[$k] =~ /0\/1/){
			$het++;
		}elsif($it[$k] =~ /1\/1/){
			$het = $het + 2;
		}else{
			print STDERR "found a missing data\n";
		}
	}
#	$sfs{$het}++;#unfolded sfs
################folded sfs
	if($het <= $lens){
		$sfs{$het}++;
	}else{
		my $tmp = $dlens - $het;
		$sfs{$tmp}++;
	}
}
foreach my $key (sort {$a<=>$b} keys %sfs){
        print STDERR "$key\t$sfs{$key}\n";
}
