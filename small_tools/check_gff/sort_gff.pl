use warnings;
use strict;
my $gff = $ARGV[0];

open GFF,$gff or die "$!\n";
my %ref;
my %other;
while (<GFF>){
	next if (/^#/);
	next if (/^\n$/);
	chomp;
	my @it = split /\t/,$_;
	if ($it[2] eq "gene"){
		$ref{$it[0]}{$it[2]}{$it[3]} = $_;
	}else{
		$it[8] =~ /^ID=(.*?);/;
		my $iid = $1;
		$it[8] =~ /;Name=(.*?);/;
		my $id = $1;
		$other{$it[0]}{$it[2]}{$id}{$iid} = $_;
	}
}
close GFF;
print STDERR "processed GFF3 file $gff\n";


foreach my $scaf (sort keys %ref){
	foreach my $pos (sort {$a <=> $b}keys %{$ref{$scaf}{"gene"}}){
		my $geneline = $ref{$scaf}{"gene"}{$pos};
		print "$geneline\n";
		my @gene = split /\t/,$geneline;
		$gene[8] =~ /^ID=(.*?);/;
		my @gid = split /\./,$1;
		my $geneid = $gid[0]."\.mrna";
		$gid[1] =~ /^path(\d+)/;
		my $path = $1;
		my $mRNAid = $geneid.$path;
		#print STDERR "$mRNAid\n";
		my $mRNAline = $other{$scaf}{"mRNA"}{$gid[0]}{$mRNAid};
		print "$mRNAline\n";
		my $mRNAidtmp = $mRNAid."\.exon";
		my $numexon = (keys %{$other{$scaf}{"exon"}{$gid[0]}});
		for (my $ee = 0;$ee <= $numexon +10;){
			my $exonid = $mRNAidtmp.$ee;
			if (defined($other{$scaf}{"exon"}{$gid[0]}{$exonid})){
				my $exonline = $other{$scaf}{"exon"}{$gid[0]}{$exonid};
				print "$exonline\n";
				$ee++;
				next;
			}else{
				$ee++;
				next;
			}
		}
		$mRNAidtmp = $mRNAid."\.cds";
                my $numcds = (keys %{$other{$scaf}{"CDS"}{$gid[0]}});
                for (my $cc = 0;$cc <= $numcds +10;){
                	my $cdsid = $mRNAidtmp.$cc;
			if (defined($other{$scaf}{"CDS"}{$gid[0]}{$cdsid})){
				my $cdsline = $other{$scaf}{"CDS"}{$gid[0]}{$cdsid};
                        	print "$cdsline\n";
				$cc++;
				next;
			}else{
				$cc++;
				next;
			}
                }   
	}
}






