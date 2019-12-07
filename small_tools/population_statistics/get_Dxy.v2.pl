#!usr/bin/perl -w
use warnings;
use strict;

die ("
Usage: perl get_Dxy.pl <pop1.dir> <pop2.dir> <window> <step> <min_coverage_bp> <start_point>

This script will calculate Dxy between pop1 and pop2 with window <window>bp, and window step <step>bp, and min coverage bp per window.
usually, start point is 1.

") unless scalar(@ARGV) == 6;

my ($pop1,$pop2,$window,$step,$min_coverage_bp,$start_point) = @ARGV;
opendir(DIR1, $pop1) || die "Can't open input directory '$pop1'\n";
my @files_pop1 = readdir(DIR1);
closedir(DIR1);
opendir(DIR2, $pop2) || die "Can't open input directory '$pop2'\n";
my @files_pop2 = readdir(DIR2);
closedir(DIR2);
my $pop1_seq = &readFAS($pop1,@files_pop1);
my $pop2_seq = &readFAS($pop2,@files_pop2);

my %pair_dxy;
my %scaf_pos;
foreach my $kk (sort keys %{$pop1_seq}){
	foreach my $aa (sort keys %{$pop2_seq}){
		my $string = $kk."_".$aa;
		$pair_dxy{$string} = &getDxy($kk,$aa,$window,$step,$min_coverage_bp,$start_point);
		my @inds_dxy;
		foreach my $scaf (sort keys %{$pair_dxy{$string}}){
				foreach my $pos (sort keys %{$pair_dxy{$string}{$scaf}}){
					$scaf_pos{$scaf}{$pos} = 1;
					push @inds_dxy,$pair_dxy{$string}{$scaf}{$pos};
				}
		}
		my $sum_dxy = 0;
		my $tmplen_dxy = @inds_dxy;
		foreach my $k (0 .. $#inds_dxy){
			if ($inds_dxy[$k] == -1){
				$tmplen_dxy--;
				next;
			}
			$sum_dxy += $inds_dxy[$k];
		}
		my $ave_dxy = $sum_dxy/$tmplen_dxy;
		my $sd_dxy = &standard_dev($ave_dxy,$tmplen_dxy,@inds_dxy);
		print STDERR "$kk\t$aa\t$ave_dxy\t$sd_dxy\n";
	}
}
my @all_Dxy;
my $sum_allDxy = 0;
my $num_allDxy = 0;
foreach my $cc (sort keys %scaf_pos){
        foreach my $dd (sort {$a <=> $b} keys %{$scaf_pos{$cc}}){
                my $num_pair = 0;
                my $tmp = 0;
                my $bin_Dxy = -1;
                foreach my $ll (sort keys %pair_dxy){
                        next if ($pair_dxy{$ll}{$cc}{$dd} == -1);
                        $num_pair++;
                        $tmp += $pair_dxy{$ll}{$cc}{$dd};
                }
                unless ($num_pair == 0){
                        $bin_Dxy = $tmp/$num_pair;
                        $num_allDxy++;
                        $sum_allDxy += $bin_Dxy;
                }
                my $start_index = $dd + 1;
                print "$cc\t$start_index\t$bin_Dxy\n";
                push @all_Dxy,$bin_Dxy;
        }
}
my $average_allDxy = $sum_allDxy/$num_allDxy;
my $sd_allDxy = &standard_dev($average_allDxy,$num_allDxy,@all_Dxy);
print STDERR "$pop1\t$pop2\t$average_allDxy\t$sd_allDxy\n";

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
	my $dir = shift;
        foreach my $file (@_){
                open POP,"\.\/$dir\/$file" or die "Can not open $file. $!\n";
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
sub getDxy(){
	my ($ind1,$ind2,$window,$step,$min_coverage_bp,$start_point) = @_;
	my %result;
	foreach my $chr (sort keys %{$pop1_seq->{$ind1}}){
		my $len = length($pop1_seq->{$ind1}{$chr});	
		next if ($len - $window < $start_point - 1);
		for (my $p = $start_point - 1;$p <= $len - $window;$p = $p + $step){
			my $tmp1 = substr($pop1_seq -> {$ind1}{$chr},$p,$window);
			my $tmp2 = substr($pop2_seq -> {$ind2}{$chr},$p,$window);
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
