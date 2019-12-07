#!/usr/bin/perl
my ($fasta,$gff3)=@ARGV;
my %seqs;
my $id;
open FA,"$fasta" || die "$!\n";
while(<FA>){
	chomp;
	if(/^>(.*)/){
	#	s/\>//g;
		$id=$1;
	}else{
		s/\s//g;
		$seqs{$id} .= $_;
	}
}
close FA;
print STDERR "processed fasta ....\n";
my %cdsSeq;
my $name;
my $strand;
my $flag=0;
my $pos;
open GFF,"$gff3" || die "$!\n";
while(<GFF>){
	chomp;
	next if (/^\#/);
	my @it = split(/\t/);
	next unless ($it[2] eq 'CDS' ||$it[2] eq 'gene');
	next unless($seqs{$it[0]});
	if ($it[2] eq 'gene'){
		print STDERR "processing $it[0] ...\n";
		$it[8] =~ /^ID=(.*?);/;
		if (defined($cdsSeq{$name})){
			if (length($cdsSeq{$name}) == 0){
				print STDERR "find a zero length gene\n";
			}
			print ">$name\n$cdsSeq{$name}\n";
			$name = $1;
			$flag = 0;
			next;	
		}else{
			$name = $1;
			$flag = 0;
			next;
		}
	}else{
		my $st = $it[3] - 1;
		my $ed = $it[4];
		my $len = $ed - $st;
		my $cds = substr($seqs{$it[0]},$st,$len);
		if ($it[6] eq '-'){
			my $cdstmp = reverse($cds);
			$cdstmp =~ tr/ATCG/TAGC/;
			$cds = $cdstmp;
			if ($flag == 0){
				$cdsSeq{$name} = $cds;
				$pos = $it[3];
				$flag++;
			}else{
				if ($it[3] > $pos){
					$cdsSeq{$name} = $cds.$cdsSeq{$name};
				}else{
					$cdsSeq{$name} .= $cds;
				}
			}
		}else{
			if ($flag == 0){
				$cdsSeq{$name} = $cds;
				$pos = $it[3];
				$flag++;
			}else{
				if ($it[3] > $pos){
					$cdsSeq{$name} .= $cds;
				}else{
					$cdsSeq{$name} = $cds.$cdsSeq{$name};
				}
			}
		}
	}
}
close GFF;
print ">$name\n$cdsSeq{$name}\n";                                                                        
print STDERR "processed gff ...\n";
=cut
foreach my $k (sort keys %cdsSeq){
	foreach my $s (sort {$a<=>$b} keys %{$cdsSeq{$k}}){
		foreach $e (sort {$a<=>$b} keys %{$cdsSeq{$k}{$s}}){
			print ">$k\|$s\|$e\n$cdsSeq{$k}{$s}{$e}\n";
		}
	}
}

	
