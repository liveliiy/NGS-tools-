use warnings;
use strict;

my ($list_file,$vcf,$pop_1,$pop_2,$hap_pop_1,$hap_pop_2) = @ARGV;
my $pop_hash = &readList($list_file);
my $sfs_hash = &readVCF($vcf,$pop_hash,$pop_1,$pop_2);
&printResult($hap_pop_1,$hap_pop_2,$sfs_hash);
sub printResult(){
	my ($hap_pop_1,$hap_pop_2,$sfs) = @_;
	my $row_name = join "\t",(map {"d0\_$_"} 0 .. $hap_pop_1);
	my @col_name = map {"d1\_$_"} 0 .. $hap_pop_2;
	print "1 observation\n";
	print "\t$row_name\n";
	foreach my $aa (0 .. $hap_pop_2){
		my $tmpname = shift @col_name;
		my $line = $tmpname;
		foreach my $kk (0 .. $hap_pop_1){
			if (exists $sfs->{$kk}{$aa}){
				$line .= "\t$sfs->{$kk}{$aa}";
			}else{
				$line .= "\t0";
			}
		}
		print "$line\n";
	}
}
sub readList(){
	my $file = shift;
	my %hash = ();
	open IN,$file or die "Can't open $file\n";
	while (<IN>){
		chomp;
		my @it = split /\t/,$_;
		push @{$hash{$it[1]}},$it[0]; 
	}
	close IN;
	return \%hash;
}
sub readVCF(){
	my ($file,$pop_hash,$pop_1,$pop_2) = @_;
	my %pop_index;
	my %sfs_hash;
	open IN,$file or die "Can't open $file\n";
	while (<IN>){
		next if (/^##/);
		chomp;
		my $minor = 0;
		my $line = $_; 
		my @it = split /\t/,$line;
		my $all_num = $#it - 9 + 1;
		%pop_index = map {$it[$_],$_} 9 .. $#it if ($line =~ /^#CHROM/);
		next if ($line =~ /^#CHROM/);
		my @tmp = map {(split/\:/,$it[$_])[0]} 9 .. $#it;
		my $snp_1 = grep $_ eq "0\/1",@tmp;
		my $snp_2 = grep $_ eq "1\/1",@tmp;
		my $snp_num = $snp_1 + ($snp_2 * 2);
		$minor = 1 if ($snp_num < $all_num);
		$minor = 0 if ($snp_num > $all_num);
		$minor = 0.5 if ($snp_num == $all_num);
		&calSFS(\@tmp,$pop_hash,\%pop_index,$minor,$pop_1,$pop_2,\%sfs_hash);
		#print STDERR "$snp_0\n";
		#print STDERR "@tmp\n";
	}
	close IN;
	return \%sfs_hash;
}
sub calSFS(){
	my ($array,$pop_hash,$index_hash,$minor,$pop_1,$pop_2,$sfs_hash) = @_;
	my %snp_hash;
	my %tmp_hash;
	my ($pop_1_num,$pop_2_num);
	foreach my $pop (keys %$pop_hash){
		$tmp_hash{$pop} = @{$pop_hash->{$pop}};
		$snp_hash{$pop} = 0;
		foreach my $aa (@{$pop_hash->{$pop}}){
			$snp_hash{$pop}++ if ($array->[$index_hash->{$aa} - 9] eq "0\/1");
			$snp_hash{$pop}+=2 if ($array->[$index_hash->{$aa} - 9] eq "1\/1");	
		}
	}
	if ($minor == 1){
		$sfs_hash->{$snp_hash{$pop_1}}{$snp_hash{$pop_2}}++;
	}elsif ($minor == 0){
		$pop_1_num = ($tmp_hash{$pop_1} * 2) - $snp_hash{$pop_1};
		$pop_2_num = ($tmp_hash{$pop_2} * 2) - $snp_hash{$pop_2};
		$sfs_hash->{$pop_1_num}{$pop_2_num}++;
	}elsif ($minor == 0.5){
		$pop_1_num = ($tmp_hash{$pop_1} * 2) - $snp_hash{$pop_1};
		$pop_2_num = ($tmp_hash{$pop_2} * 2) - $snp_hash{$pop_2};
		$sfs_hash->{$snp_hash{$pop_1}}{$snp_hash{$pop_2}} += 0.5;
		$sfs_hash->{$pop_1_num}{$pop_2_num} += 0.5;
	}
}

=cut
foreach my $aa (keys %$pop_index){
	print "$aa=>$pop_index->{$aa}\n";
}
