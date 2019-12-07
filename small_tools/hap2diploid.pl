#!usr/bin/perl -w
use warnings;
use strict;
my $in = $ARGV[0];
open(IN,"<$in") or die "can't open it$!\n";
my @sequence;
my $flag=0;
my $name1=0;
my $name2=0;
my $sequence;
while(<IN>){
	if(/\s+(\d+)\s+(\d+)/){
		my $seqnum = $1 / 2;
		print " $seqnum  $2\n";
		next;
	}
	if(/(\w+)\s+(\S+)/ && $flag==0){
		$sequence=$2;
		$name1=$1;
		@sequence=split(//,$sequence);
		$flag=1;
		next;
	}
	if(/(\w+)\s+(\S+)/ && $flag==1){
		$name2=$1;
		my $tmp=$2;
		my $lengthi=length($tmp);
		my @tmp=split(//,$tmp);
		for (my $i=0;$i<$lengthi;$i++){
			if($tmp[$i] ne $sequence[$i]){
				if($tmp[$i] eq "A" and $sequence[$i] eq "G"){
					$tmp[$i]="R";
					$sequence[$i]="R";
				}
				elsif($tmp[$i] eq "G" and $sequence[$i] eq "A"){
                                        $tmp[$i]="R";
                                        $sequence[$i]="R";
                                }   
				elsif($tmp[$i] eq "C" and $sequence[$i] eq "T"){
                                        $tmp[$i]="Y";
                                        $sequence[$i]="Y";
                                }
				elsif($tmp[$i] eq "T" and $sequence[$i] eq "C"){
                                        $tmp[$i]="Y";
                                        $sequence[$i]="Y";
                                }
				elsif($tmp[$i] eq "A" and $sequence[$i] eq "C"){
                                        $tmp[$i]="M";
                                        $sequence[$i]="M";
                                }
				elsif($tmp[$i] eq "C" and $sequence[$i] eq "A"){
                                        $tmp[$i]="M";
                                        $sequence[$i]="M";
                                }
				elsif($tmp[$i] eq "G" and $sequence[$i] eq "T"){
                                        $tmp[$i]="K";
                                        $sequence[$i]="K";
                                }
				elsif($tmp[$i] eq "T" and $sequence[$i] eq "G"){
                                        $tmp[$i]="K";
                                        $sequence[$i]="K";
                                }
				elsif($tmp[$i] eq "G" and $sequence[$i] eq "C"){
                                        $tmp[$i]="S";
                                        $sequence[$i]="S";
                                }
				elsif($tmp[$i] eq "C" and $sequence[$i] eq "G"){
                                        $tmp[$i]="S";
                                        $sequence[$i]="S";
                                }
				elsif($tmp[$i] eq "A" and $sequence[$i] eq "T"){
                                        $tmp[$i]="W";
                                        $sequence[$i]="W";
                                }
				elsif($tmp[$i] eq "T" and $sequence[$i] eq "A"){
                                        $tmp[$i]="W";
                                        $sequence[$i]="W";
                                }
			}
		}
		$sequence=join('',@sequence);
		$tmp=join('',@tmp);
		print"$name1\t$sequence\n$name2\t$tmp\n";
		$flag=0;
		next;
	}
}
