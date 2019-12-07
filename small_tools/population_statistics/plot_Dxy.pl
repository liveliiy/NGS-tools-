#prefix = admix_Dxy_type2
use warnings;
use strict;

my ($list,$prefix,$pop1,$pop2,$window,$step) = @ARGV;

my $gene_hash = &readLIST($list);
foreach my $kk (sort keys %{$gene_hash}){
	my $file = "$prefix\_$kk\.txt";
	foreach my $cc (sort keys %{$gene_hash->{$kk}}){
		my ($start,$end,$qian_Fst,$avechr_dxy) = split /\%/,$gene_hash->{$kk}{$cc};
		my ($pos1,$pos2,$pos3,$pos4)= &readTXT($file,$start,$end,$window,$step);
		&plot_inR($file,$pos1,$pos2,$pos3,$pos4,$kk,$cc,$pop1,$pop2,$qian_Fst,$avechr_dxy);
	}
}

sub readLIST(){
	my $file = shift;
	my %gene_list;
	open LI,$file or die "Can't open $file. $!\n";
	while (<LI>){
		my @it = split /\t/,$_;
		$gene_list{$it[0]}{$it[1]} = $it[2]."%".$it[3]."%".$it[4]."%".$it[5];
	}
	close LI;
	return \%gene_list;
}

sub readTXT(){
	my ($file,$start,$end,$window,$step) = @_;
	my $start1 = $start - $window - 100 * $step;
	my $end1 = $end + 100 * $step;
	my ($pos1,$pos2,$pos3,$pos4) = (0,0,0,0);
	open TXT,$file or die "Can't open $file. $!\n";
	my ($flag1,$flag2,$flag3,$flag4) = (0,0,0,0);
	my $store;
	while (<TXT>){
		chomp;
		next if (/^SNP\s/);
		my @it = split /\t/,$_; 
		if ($it[2] >= $start1 && $flag1 == 0){
			$pos1 = $it[2];
			$flag1 = 1;
		}elsif ($it[2] >= ($start - $window) && $flag3 == 0){
			$pos3 = $it[2] - 1;
			$flag3 = 1;
		}elsif ($it[2] >= $end && $flag4 == 0){
			$pos4 = $it[2] - 1;
			$flag4 = 1;
		}elsif ($it[2] >= $end1 && $flag2 == 0){
                        $pos2 = $it[2];
                        $flag2 = 1;
                        last;
		}
		$store = $it[2];
	}
	close TXT;
	if ($pos2 == 0){
		$pos2 = $store;
	}
	if ($pos4 == 0){
		$pos4 = $store;
	}
	return ($pos1,$pos2,$pos3,$pos4);
}

#args <- commandArgs()
sub plot_inR(){
	my ($file,$pos1,$pos2,$pos3,$pos4,$chr,$gene,$pop1,$pop2,$qian_Fst,$avechr_dxy) = @_;
	my $string=<<HOPE;
data <- read.table("$file",header = T)
gene_table <- data[data\$pos >= $pos1 & data\$pos <= $pos2,]
gene_frame <- data.frame(pos = rep(gene_table\$pos,2),
                      num=c(gene_table\$Fst,gene_table\$Dxy),
                      name = c(rep("Fst",dim(gene_table)[1]),rep("Dxy",dim(gene_table)[1]))
                      )
library(ggplot2)
library(gridExtra)
avg1 <- ggplot(gene_frame[gene_frame\$name=="Fst",],aes(x=pos,y=num)) +
  geom_point() +
  geom_vline(aes(xintercept=$pos3), colour="lightseagreen", linetype="dashed")+
  geom_vline(aes(xintercept=$pos4), colour="lightseagreen", linetype="dashed")+
  geom_hline(aes(yintercept=$qian_Fst), colour="#990000", linetype="dashed")+
  facet_wrap(~name)+theme_bw() +
  coord_cartesian(ylim=c(0,1)) +
  ylab("") + xlab("$pop1\_$pop2 $chr $gene")
avg2 <- ggplot(gene_frame[gene_frame\$name=="Dxy",],aes(x=pos,y=num)) +
  geom_point() +
  geom_vline(aes(xintercept=$pos3), colour="lightseagreen", linetype="dashed")+
  geom_vline(aes(xintercept=$pos4), colour="lightseagreen", linetype="dashed")+
  geom_hline(aes(yintercept=$avechr_dxy), colour="#990000", linetype="dashed")+
  facet_wrap(~name)+theme_bw() +
  coord_cartesian(ylim=c(0,0.05)) +
  ylab("") + xlab("$pop1\_$pop2 $chr $gene")
pdf("./$pop1\_$pop2\_$chr\_$gene.pdf")
grid.arrange(avg1,avg2)
dev.off()
HOPE
	open OUT,">$pop1\_$pop2\_$chr\_$gene.R" or die "Can't open $pop1\_$pop2\_$chr\_$gene.R. $!\n";
	print OUT "$string";
	close OUT;
	`Rscript $pop1\_$pop2\_$chr\_$gene.R`;
}


###################################
