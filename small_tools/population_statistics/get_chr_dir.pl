#!usr/bin/perl -w
use warnings;
use strict;

die ("
Usage: perl get_chr_dir.pl <input_dir> <individuals_list> <chr_name> <output_dir>

This script will extract individua's fasta with the chr.

") unless scalar(@ARGV) == 4;

my ($input_dir,$ind_list,$chr_name,$output_dir) = @ARGV;
`mkdir -p $output_dir`;
my @files;
open IN,$ind_list or die "Can't open ind lists.\n";
while (<IN>){
	chomp;
	push @files,$_;
}
close IN;

foreach my $kk (@files){
	&readFAS($input_dir,$kk,$chr_name,$output_dir);
}

sub readFAS(){
	my ($input_dir,$ind,$chr_name,$output_dir) = @_;
	open FAS,"$input_dir\/$ind\.mask\.fasta" or die "Can't open $ind.$!\n";
	open OUT,">$output_dir\/$ind\.fasta" or die "Can't open $ind\.fasta.  $!\n";
	my $flag = 0;
	while (<FAS>){
		chomp;
		if (/^>(\S+)/){
			if ($chr_name eq $1){
				$flag = 1;
				print OUT ">$chr_name\n";
			}else{
				$flag = 0;
			}
		}elsif ($flag == 1){
			s/\s//g;
			print OUT "$_\n";
		}
	}
	close OUT;
	close FAS;
}

