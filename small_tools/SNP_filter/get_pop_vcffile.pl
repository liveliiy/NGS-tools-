#!usr/bin/perl -w
use warnings;
use strict;
use POSIX;
die("

Usage : perl POP_sfs_vcf.pl <poplist> <vcf> 1>result.out 2>log 

\n")unless scalar(@ARGV) == 2;
##############################input################################################################
my ($poplist,$vcf) = @ARGV;
my $inds_array = &readPOPlist($poplist);
&readVCF($inds_array,$vcf);
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
sub readVCF(){
	print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
	my ($inds_array,$file) = @_;
	my @index = ();
	#my %hash;
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
			print "$headline\n";
		}else{
			my @arr = ();
			my $flag = 0;
			($scaf,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@arr) = split /\t/,$_;
			if (length($ref) >=2 || length($alt) >=2){
				$flag = 1;
			}else{
				foreach my $cc (@index){
					$arr[$cc] =~ /^(.*?):/;
					my $gtype = $1;
					if ($gtype eq "\.\/\."){
						$flag = 1;
						last;
					}
				}
			}
			if ($flag == 1){
				print "$scaf\t$pos\tF\n";
				#$hash{$scaf}{$pos} = "F";
			}else{
				my $line = "$scaf\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\t$format";
				foreach my $kk (@index){
					$line .= "\t$arr[$kk]";
				}
				print "$line\n";
				#$hash{$scaf}{$pos} = $line;
			}
		}
	}
	close IN;
	print STDERR "read vcf done\n";   
	print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
	#return ($headline,\%hash);
}
##############################end######################################################################
















