#!usr/bin/perl -w
use warnings;
use strict;
die ("
Usage: perl get_Pi.pl <pop.dir> <window> <step> <min_coverage_bp> <start_point>

This script will calculate pi in pop with window <window>bp, and window step <step>bp, and min coverage <min_coverage_bp>bp per window.
usually, start point is 1.(start point is the start of the whole genome.)

") unless scalar(@ARGV) == 5;
###read input information###
my ($inputDir,$window,$step,$min_coverage_bp,$start_point) = @ARGV;
opendir(DIR, $inputDir) || die "Can't open input directory '$inputDir'\n";
my @files = readdir(DIR);
closedir(DIR);
my $pop_seq = &readFAS(@files);
###main function###
my %pair_pi;
my %scaf_pos;
my @individuals = (sort keys %{$pop_seq});
foreach my $aa (0 .. $#individuals-1){
	foreach my $bb ($aa+1 .. $#individuals){
		my $string = $individuals[$aa]."_".$individuals[$bb];
		$pair_pi{$string} = &getPi($individuals[$aa],$individuals[$bb],$window,$step,$min_coverage_bp,$start_point);
		my @inds_pi;
		foreach my $scaf (sort keys %{$pair_pi{$string}}){
			foreach my $pos (sort keys %{$pair_pi{$string}{$scaf}}){
				$scaf_pos{$scaf}{$pos} = 1;
				push @inds_pi,$pair_pi{$string}{$scaf}{$pos};
			}
		}
		my $sum_pi = 0;
		my $tmplen_pi = @inds_pi;
		foreach my $k (0 .. $#inds_pi){
			if ($inds_pi[$k] == -1){
				$tmplen_pi--;
				next;
			}
			$sum_pi += $inds_pi[$k];
		}
		my $ave_pi = $sum_pi/$tmplen_pi;
		my $sd_pi = &standard_dev($ave_pi,$tmplen_pi,@inds_pi);
		print STDERR "$individuals[$aa]\t$individuals[$bb]\t$ave_pi\t$sd_pi\n";
	}
}
my @all_Pi;
my $sum_allPi = 0;
my $num_allPi = 0;
foreach my $cc (sort keys %scaf_pos){
	foreach my $dd (sort {$a <=> $b} keys %{$scaf_pos{$cc}}){
		my $num_pair = 0;
		my $tmp = 0;
		my $bin_Pi = -1;
		foreach my $ll (sort keys %pair_pi){
			next if ($pair_pi{$ll}{$cc}{$dd} == -1);
			$num_pair++;
			$tmp += $pair_pi{$ll}{$cc}{$dd};
		}
		unless ($num_pair == 0){
			$bin_Pi = $tmp/$num_pair;
			$num_allPi++;
			$sum_allPi += $bin_Pi;
		}
		my $start_index = $dd + 1;
		print "$cc\t$start_index\t$bin_Pi\n";
		push @all_Pi,$bin_Pi;
	}
}
my $average_allPi = $sum_allPi/$num_allPi;
my $sd_allPi = &standard_dev($average_allPi,$num_allPi,@all_Pi);
print STDERR "$inputDir\t$average_allPi\t$sd_allPi\n";
###information lists and sub function###
my %degenerate_base = (
	'R' => ["A","G"],
	'Y' => ["C","T"],
	'M' => ["A","C"],
	'K' => ["G","T"],
	'S' => ["G","C"],
	'W' => ["A","T"]
);
sub standard_dev(){
	my ($ave,$N,@array) = @_;
	my $square_sum = 0;
	foreach my $element (@array){
		next if ($element == -1);
		$square_sum += ($element - $ave) ** 2;
	}
	my $sd = sqrt($square_sum/($N-1));
	return $sd;
}
sub readFAS(){
	my %seq;
	foreach my $file (@_){
		open POP,"\.\/$inputDir\/$file" or die "Can not open $file. $!\n";
		my $chr_name = "";
		$file =~ /^(.*?)\./;
		my $ind_name = $1;	
		while (<POP>){
			chomp;
			if (/^>(\S+)/){
				$chr_name = $1;
			}else{
				s/\s//g;
				$seq{$ind_name}{$chr_name} .= $_;
			}			
		}
		close POP;
	}
	return \%seq;
}
sub getPi(){
	my ($ind1,$ind2,$window,$step,$min_coverage_bp,$start_point) = @_;
	my %result;
	foreach my $chr (sort keys %{$pop_seq->{$ind1}}){
		my $len = length($pop_seq->{$ind1}{$chr});
		next if ($len - $window < $start_point - 1);
		for (my $p = $start_point - 1;$p <= $len - $window;$p = $p + $step){
			my $tmp1 = substr($pop_seq->{$ind1}{$chr},$p,$window);
			my $tmp2 = substr($pop_seq->{$ind2}{$chr},$p,$window);	
			my $denominator = 0;
			my $diff = 0;
			for (my $i = 0;$i < $window;$i++){
				my $site1 = substr($tmp1,$i,1);
				my $site2 = substr($tmp2,$i,1);
				next if ($site1 eq "N" || $site2 eq "N");
				$denominator++;
				next if ($site1 eq $site2 && $site1 =~ /[ATCG]/);
				if($site1 =~ /[SRYKMW]/ && $site2 =~ /[SRYKMW]/){
					if ($site1 eq $site2){
						$diff+=0.5;
					}else{
						my $ff = 0;
						foreach my $ii (@{$degenerate_base{$site1}}){
							if ($ii ~~ @{$degenerate_base{$site2}}){
								$ff = 1;
								last;
							}
						}
						if ($ff == 1){
							$diff+=0.75;
						}else{
							$diff+=1;
						}
					}
				}elsif($site1 =~ /[SRYKMW]/ && $site2 =~ /[ATCG]/){
					if ($site2 ~~ @{$degenerate_base{$site1}}){
						$diff+=0.5;
					}else{
						$diff+=1;
					}
				}elsif($site2 =~ /[SRYKMW]/ && $site1 =~ /[ATCG]/){
					if ($site1 ~~ @{$degenerate_base{$site2}}){
						$diff+=0.5;
					}else{
						$diff+=1;
					}
				}else{
					$diff++;
				}
			}	
			my $ratio;
			if($denominator <= $min_coverage_bp){
				$ratio = -1;
			}else{
				$ratio = $diff/$denominator;
			}
			$result{$chr}{$p} = $ratio;
		}
	}
	return \%result;
}	
