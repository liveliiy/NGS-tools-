#!usr/bin/perl -w
use warnings;
use strict;
#die("
#Usage :
#")unless scalar(@ARGV) == 6;
my ($poplist,$avedep_list,$dep_list,$dep_file,$gff,$vcf) = @ARGV;

my $inds_array = &readPOPlist($poplist);
print "read poplist done\n";
my $avedep_hash = &readAVEDEPlist($avedep_list);
print "read avedep_list done\n";
my $cds_hash = &readGFF($gff);
print "read gff done\n";
my $depindex_hash = &readDEPINDEXlist($dep_list);
print "read dep_list done\n";
my $dep_hash = &readDEP($dep_file,$depindex_hash,$inds_array,$avedep_hash,$cds_hash);
print "read dep file done\n";
my ($headline,$vcf_hash) = &readVCF($inds_array,$vcf);
print "read vcf done\n";

sub readPOPlist(){
	my $file = shift;
	my @inds = ();
	open IN,$file or die "Can't open $file $!\n";
	while (<IN>){
		chomp;
		push @inds,$_;
	}
	close IN;
	return \@inds;
}
sub readAVEDEPlist(){
	my $file = shift;
	my %hash = ();
	open IN,$file or die "Can't open $file $!\n";
	while (<IN>){
		chomp;
		my @it = split /\s+/,$_;
		$hash{$it[0]} = $it[1];
	}
	close IN;
	return \%hash;
}
sub readGFF(){
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
	return \%hash;
}
sub readDEPINDEXlist(){
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
	return \%hash;  
}
sub readDEP(){
	my ($file,$depindex_hash,$inds_array,$avedep_hash,$cds_hash) = @_;
	my %tmp = ();
	my %hash = ();
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
			$hash{$scaf}{$pos} = 0;
			next;
		}
		my $flag = 0;
		foreach my $cc (0 .. $#deps){
			if ($cc ~~ (keys %tmp)){
				my $min = $tmp{$cc} * (1/3);
				if ($min < 6){
					$min = 6;
				}
				my $max = $tmp{$cc} * 2;
				if ($deps[$cc] >= $max || $deps[$cc] <= $min){
					$flag = 1;
				}
			}
		}
		if ($flag == 0){
			$hash{$scaf}{$pos} = 1;
		}else{
			$hash{$scaf}{$pos} = 0;
		}
	}
	close IN;
	return \%hash;
}
sub readVCF(){
	my ($inds_array,$file) = @_;
	my @index = ();
	my %hash;
	my $headline = "";
	open IN,$file or die "Can't open $file $!\n";
	while (<IN>){
		chomp;
		next if (/^##/);
		my ($scaf,$pos,$id,$ref,$alt,$qual,$filter,$info,$format);
		if (/^#CHROM/){
			my @ids;
			($scaf,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@ids) = split /\t/,$_;
			$headline = "$scaf\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\t$format";
			foreach my $aa (0 .. $#ids){
				if ($ids[$aa] ~~ @$inds_array){
					push @index,$aa;
					$headline .= "\t$ids[$aa]";
				}
			}
		}else{
			my @arr = ();
			my $flag = 0;
			($scaf,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@arr) = split /\t/,$_;
			if (length($ref) >=2 || length($alt) >=2){
				$flag = 1;
			}else{
				foreach my $cc (0 .. $#arr){
					$arr[$cc] =~ /^(.*?):/;
					my $gtype = $1;
					if ($cc ~~ @index){
						if ($gtype eq "\.\/\."){
							$flag = 1;
						}
					}
				}
			}
			if ($flag == 1){
				$hash{$scaf}{$pos} = "F";
			}else{
				my $line = "$scaf\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\t$format";
				foreach my $kk (@index){
					$line .= "\t$arr[$kk]";
				}
				$hash{$scaf}{$pos} = $line;
			}
		}
	}
	close IN;
	return ($headline,\%hash);
}

















