use strict;
use warnings;

open IN,"gzip -dc $ARGV[0]|" or die;
#open IN,"$ARGV[0]" or die;
open LI,"$ARGV[1]" or die;
open OUT,">$ARGV[2]" or die;

my %list;
my $cou = 8;
while (<LI>){
	chomp;
	$cou++;
	my @it = split /\t/,$_;
	$list{$cou} = $it[1];
}
close LI;

while (my $line =<IN>){
	chomp $line;
	if ($line =~ /^#/){
		print OUT "$line\n";
		next;
	}
	my @array = split /\t/,$line;
	if (length($array[3]) >1 || length($array[4]) >1){
		my $line2 = join("\t",@array);
		print OUT "$line2\n";
		next;
	}
	foreach my $i (9 .. $#array){
		if ($array[$i] =~ /(.*?):(.*?):(\d+):/){
			my ($gtype,$ad,$dp) = ($1,$2,$3);
			my $min = $list{$i}*(1/3);
			if ($list{$i} <= 18){
				$min = 6;
			}
			my $max = $list{$i}*2;
			if ($dp <= $min || $dp >=$max ){
				$array[$i] =~ s/0\/1/\.\/\./g;
				$array[$i] =~ s/0\/0/\.\/\./g;
				$array[$i] =~ s/1\/1/\.\/\./g;
			}
		}
	}
	my $line2 = join("\t",@array);
	print OUT "$line2\n";
}
close IN;
