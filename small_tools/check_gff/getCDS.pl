#!/usr/bin/perl
my ($fasta,$gff3)=@ARGV;
my %seqs;
my $id;
open FA,"$fasta" || die "$!\n";
while(<FA>){
	chomp;
	if(/>/){
		s/\>//g;
		$id=$_;
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
open GFF,"$gff3" || die "$!\n";
while(<GFF>){
	chomp;
	next if (/^\#/);
	my @it = split(/\t/);
	next unless ($it[2] eq 'CDS' ||$it[2] eq 'mRNA');
	next unless($seqs{$it[0]});
	if ($it[2] eq 'mRNA'){
		print STDERR "processing $it[0] ...\n";
		$it[8] =~ /^ID=(.*?);/;
		if (defined($cdsSeq{$name})){
			if (length($cdsSeq{$name}) == 0){
				print STDERR "find a zero length mRNA\n";
			}
			print ">$name\n$cdsSeq{$name}\n";
			$name = $1;
			next;	
		}else{
			$name = $1;
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
		}
		$cdsSeq{$name} .= $cds; 
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

	
