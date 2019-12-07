#!usr/bin/perl -w
use warnings;
use strict;
use POSIX;
die("

Usage : perl POP_sfs_vcf.pl <poplist> <avedep_list> <dep_index_list> <dep_file> <gff> 1>result.out 2>log 

\n")unless scalar(@ARGV) == 5;
##############################input################################################################
my ($poplist,$avedep_list,$dep_list,$dep_file,$gff) = @ARGV;
my $inds_array = &readPOPlist($poplist);
my $avedep_hash = &readAVEDEPlist($avedep_list);
my $cds_hash = &readGFF($gff);
my $depindex_hash = &readDEPINDEXlist($dep_list);
&readDEP($dep_file,$depindex_hash,$inds_array,$avedep_hash,$cds_hash);
##############################sub functions#########################################################
sub readPOPlist(){
	print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
	my $file = shift;
	my @inds = ();
	open IN,$file or die "Can't open $file $!\n";
	while (<IN>){
		chomp;
		push @inds,$_;
	}
	close IN;
	print STDERR "read poplist done\n";
	print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
	return \@inds;
}
sub readAVEDEPlist(){
	print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
	my $file = shift;
	my %hash = ();
	open IN,$file or die "Can't open $file $!\n";
	while (<IN>){
		chomp;
		my @it = split /\s+/,$_;
		$hash{$it[0]} = $it[1];
	}
	close IN;
	print STDERR "read avedep_list done\n"; 
	print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
	return \%hash;
}
sub readGFF(){
	print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
	my $file = shift;
	my %hash = ();
	open IN,$file or die "Can't open $file $!\n";
	while (<IN>){
		chomp;
		my @it = split /\t/,$_;
		if ($it[2] eq "CDS" || $it[2] eq "five_prime_UTR" || $it[2] eq "three_prime_UTR" ){
			foreach my $kk ($it[3] .. $it[4]){
				$hash{$it[0]}{$kk} = "CDS";
			}
		}
	}
	close IN;
	print STDERR "read gff done\n";     
	print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
	return \%hash;
}
sub readDEPINDEXlist(){
	print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
	my $file = shift;
	my %hash = ();
	my $count = -1;
	open IN,$file or die "Can't open $file $!\n";
	while (<IN>){
		chomp;
		$count++;
		$hash{$_} = $count;
	}
	close IN;
	print STDERR "read dep_index_list done\n"; 
	print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
	return \%hash; 
}
sub readDEP(){
	print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
	my ($file,$depindex_hash,$inds_array,$avedep_hash,$cds_hash) = @_;
	my %tmp = ();
	#my %hash = ();
	foreach my $aa (keys %{$depindex_hash}){
		if ($aa ~~ @$inds_array){
			$tmp{$depindex_hash->{$aa}} = $avedep_hash->{$aa};
		}
	}
	open IN,$file or die "Can't open $file $!\n";
	while (<IN>){
		chomp; 
		my ($scaf,$pos,@deps) = split /\s+/,$_;
		if (exists $cds_hash->{$scaf}{$pos} && $cds_hash->{$scaf}{$pos} eq "CDS"){
			#$hash{$scaf}{$pos} = 0;
			print "$scaf\t$pos\tF\n";
			next;
		}
		my $flag = 0;
		my @test = (keys %tmp);
		foreach my $cc (@test){
			my $min = $tmp{$cc} * (1/3);
			if ($min < 6){
				$min = 6;
			}
			my $max = $tmp{$cc} * 2;
			if ($deps[$cc] >= $max || $deps[$cc] <= $min){
				$flag = 1;
				#$hash{$scaf}{$pos} = 0;
				last;
			}
		}
		if ($flag == 0){
			print "$scaf\t$pos\tT\n";
			#$hash{$scaf}{$pos} = 1;
		}else{
			print "$scaf\t$pos\tF\n";
		}
	}
	close IN;
	print STDERR "read dep file done\n";   
	print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
	#return \%hash;
}
