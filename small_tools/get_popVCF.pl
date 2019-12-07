use warnings;
use strict;

my ($vcf,$pop) = @ARGV;
my ($pop1,$pop2,$pop3) = ("JAI","JMAD","JCAT");

open POP,$pop or die "$!\n";
my %poplist;
while (<POP>){
	chomp;
	my @it = split /\t/,$_;
	$poplist{$it[0]} = $it[1];
}
close POP;

open POP1,">$pop1.BQN.vcf" or die "$!\n";
open POP2,">$pop2.BQN.vcf" or die "$!\n";
open POP3,">$pop3.BQN.vcf" or die "$!\n";


open VCF,$vcf or die "$!\n";
my ($id_1,$id_2,$id_3) = ("","","");
my %idIND;
while (<VCF>){
	chomp;
	if (/^##/){
		print POP1 "$_\n";
		print POP2 "$_\n";
		print POP3 "$_\n";
	}elsif (/^#CHROM/){
		my @id = split /\t/,$_;
		foreach my $ii (9 .. $#id){
			next unless (defined($poplist{$id[$ii]}));
			if ($poplist{$id[$ii]} eq $pop1){
				$id_1 .= "$id[$ii]\t";
				$idIND{$ii} = $pop1;
			}elsif ($poplist{$id[$ii]} eq $pop2){
				$id_2 .= "$id[$ii]\t";
				$idIND{$ii} = $pop2;
			}elsif ($poplist{$id[$ii]} eq $pop3){
				$id_3 .= "$id[$ii]\t";
				$idIND{$ii} = $pop3;
			}else{
				print STDERR "Warning: find a individual not in the poplist\n";
			}
		}
		$id_1 =~ s/\t$//g;
		$id_2 =~ s/\t$//g;
		$id_3 =~ s/\t$//g;
		print POP1 "$id[0]\t$id[1]\t$id[2]\t$id[3]\t$id[4]\t$id[5]\t$id[6]\t$id[7]\t$id[8]\t$id_1\n";
		print POP2 "$id[0]\t$id[1]\t$id[2]\t$id[3]\t$id[4]\t$id[5]\t$id[6]\t$id[7]\t$id[8]\t$id_2\n";
		print POP3 "$id[0]\t$id[1]\t$id[2]\t$id[3]\t$id[4]\t$id[5]\t$id[6]\t$id[7]\t$id[8]\t$id_3\n";
	}else{
		my @arr = split /\t/,$_;
		my ($tmp1,$tmp2,$tmp3) = ("","","");
		foreach my $ii (9 .. $#arr){
			next unless (defined($idIND{$ii}));
			if ($idIND{$ii} eq $pop1){
				$tmp1 .= "$arr[$ii]\t";
			}elsif ($idIND{$ii} eq $pop2){
				$tmp2 .= "$arr[$ii]\t";
			}elsif ($idIND{$ii} eq $pop3){
				$tmp3 .= "$arr[$ii]\t";
			}else{
				print STDERR "Warning: find a SNP not in the poplist\n";
			}
		}
		$tmp1 =~ s/\t$//g;
		$tmp2 =~ s/\t$//g;
		$tmp3 =~ s/\t$//g;
		print POP1 "$arr[0]\t$arr[1]\t$arr[2]\t$arr[3]\t$arr[4]\t$arr[5]\t$arr[6]\t$arr[7]\t$arr[8]\t$tmp1\n";
		print POP2 "$arr[0]\t$arr[1]\t$arr[2]\t$arr[3]\t$arr[4]\t$arr[5]\t$arr[6]\t$arr[7]\t$arr[8]\t$tmp2\n";
		print POP3 "$arr[0]\t$arr[1]\t$arr[2]\t$arr[3]\t$arr[4]\t$arr[5]\t$arr[6]\t$arr[7]\t$arr[8]\t$tmp3\n";
	}
}
close POP1;
close POP2;
close POP3;
