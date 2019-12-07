my ($list1,$list2) = @ARGV;

open LI1,$list1 or die;
my @list1;
while (<LI1>){
	chomp;
	unless ($_ ~~ @list1){
		push @list1,$_;
	}
}
close LI1;

open LI2,$list2 or die;
my @list2;
while (<LI2>){
	chomp;
	unless ($_ ~~ @list2){
		push @list2,$_;
	}
}
close LI2;

foreach my $ii (@list1){
	foreach my $jj (@list2){
		if ($ii eq $jj){
			print "$jj\n";
		}
	}
}
