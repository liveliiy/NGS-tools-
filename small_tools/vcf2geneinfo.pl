use warnings;
use strict;
my ($vcf,$gff) = @ARGV;

open VCF,$vcf or die "$!\n";
my %snp;
while (<VCF>){
	next if (/^#/);
	chomp;
	my @it = split /\t/,$_;
	$snp{$it[0]}{$it[1]} = 1;
}
close VCF;
print STDERR "processed VCF file $vcf\n";

open GFF,$gff or die "$!\n";
my %ref;
while (<GFF>){
	next if (/^#/);
	chomp;
	my @it = split /\t/,$_;
	next unless ($it[2] eq "gene" or $it[2] eq "CDS");
	foreach my $aa ($it[3] .. $it[4]){
		$ref{$it[0]}{$aa} = $it[2];
	}	
}
close GFF;
print STDERR "processed GFF3 file $gff\n";

my ($all,$num_cds,$num_intron,$num_intergenic);
foreach my $scaf (sort keys %snp){
	foreach my $pos (sort {$a <=> $b}keys %{$snp{$scaf}}){
		$all++;
		if (defined($ref{$scaf}{$pos})){
			if ($ref{$scaf}{$pos} eq "CDS"){
				$num_cds++;
			}elsif ($ref{$scaf}{$pos} eq "gene"){
				$num_intron++;
			}else{
				print STDERR "find a $ref{$scaf}{$pos}\n";
			}
		}else{
			$num_intergenic++;	
		}
	}
}
print "All:\t$all\nCDS:\t$num_cds\nINTRON:\t$num_intron\nINTER-GENIC:\t$num_intergenic\n";
my $ratio_cds = $num_cds/$all;
my $ratio_intron = $num_intron/$all;
my $ratio_intergenic = $num_intergenic/$all;
print "CDS:\t$ratio_cds\nINTRON:\t$ratio_intron\nINTER-GENIC:\t$ratio_intergenic\n";
=cut
foreach my $scaf (sort keys %snp){
	foreach my $pos (sort {$a <=> $b}keys %{$snp{$scaf}}){
		my $flag = 0;
#####################if it in a CDS#################################################################################################
		foreach my $start (sort keys %{$ref{$scaf}{"CDS"}}){
			print STDERR "$start%$pos\n";
			if ($start <= $pos){
				print STDERR "find a CDS start\n";
				my @end = keys %{$ref{$scaf}{"CDS"}{$start}};
				if ($end[0] >= $pos){
					print STDERR "find a CDS end\n";
					my @note = split /\t/,$ref{$scaf}{"CDS"}{$start}{$end[0]};
					print "$snp{$scaf}{$pos}\t$note[2]\t$note[3]\t$note[4]\t$note[6]\t$note[7]\t$note[8]\n";
					$flag = 1;
					last;
				}
			}else{
				next;
			}
		}
		next if ($flag == 1);
#####################if it in a intron############################################################################################
		foreach my $start (sort keys %{$ref{$scaf}{"gene"}}){
			if ($start <= $pos){
				print STDERR "find a intron start\n";
				my @end = keys %{$ref{$scaf}{"gene"}{$start}};
				if ($end[0] >= $pos){
					print STDERR "find a intron end\n";
					my @note = split /\t/,$ref{$scaf}{"gene"}{$start}{$end[0]};
					print "$snp{$scaf}{$pos}\tintron\t$note[3]\t$note[4]\t$note[6]\t$note[7]\t$note[8]\n";
					$flag = 1;
					last;
				}
			}else{
				next;
			}
		}
		next if ($flag == 1);
#####################if it in a intergenic#########################################################################################
		print "$snp{$scaf}{$pos}\tinter-gene\t.\t.\t.\t.\t.\n";
	}

}
