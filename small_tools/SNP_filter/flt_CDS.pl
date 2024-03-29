use warnings;
use strict;
use POSIX;

my ($l_file,$vcf,$gff,$step) = @ARGV;
my $l_hash = &readLength($l_file);
my $cds_hash = &readGFF($gff,$l_hash,$step);
&readVCF($vcf,$cds_hash);

sub readLength(){
	my $file = shift;
	open IN,$file or die "Can't open $file\n";
	my %hash = ();
	while (<IN>){
		next if (/^ID/);
		chomp;
		my @it = split /\t/,$_;
		$hash{$it[0]} = $it[1];
	}
	close IN;
	return \%hash;
}

sub readVCF(){
        print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
        my ($file,$cds_hash) = @_;
	my $cdsNUM=0;
	my $sum = 0;
        open IN,$file or die "Can't open $file $!\n";
        while (<IN>){
		print "$_" if (/^#/);
		next if (/^#/);
                chomp;
		$sum++;
                my ($scaf,$pos,@junk) = split /\t/,$_;
		next if (exists $cds_hash->{$scaf}{$pos});
		print "$_\n";
        }
        close IN;
	#my $ratio = $cdsNUM/$sum;
	#print STDERR "cds num : $cdsNUM\tall num : $sum\tratio : $ratio\n";
        print STDERR "read dep file done\n";
        print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
}

sub readGFF(){
        print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
        my ($file,$l_hash,$step) = @_;
        my %hash = ();
        open IN,$file or die "Can't open $file $!\n";
        while (<IN>){
                chomp;
		my ($start,$end);
                my @it = split /\t/,$_;
                if ($it[2] eq "CDS" || $it[2] eq "five_prime_UTR" || $it[2] eq "three_prime_UTR" ){
			if ($it[2] eq "CDS" && exists $l_hash->{$it[0]}){
				if ($it[3] - $step > 1){
					$start = $it[3] - $step;
				}else{
					$start = 1;
				}
				if ($it[4] + $step < $l_hash->{$it[0]}){
					$end = $it[4] + $step;
				}else{
					$end = $l_hash->{$it[0]};
				}
			}else{
				$start = $it[3];
				$end = $it[4];
			}
                        foreach my $kk ($start .. $end){
				next if (exists $hash{$it[0]}{$kk});
                                $hash{$it[0]}{$kk} = "CDS";
                        }
                }
        }
        close IN;
        print STDERR "read gff done\n";
        print STDERR strftime("%Y-%m-%d %H:%M:%S", localtime)."\n";
        return \%hash;
}

