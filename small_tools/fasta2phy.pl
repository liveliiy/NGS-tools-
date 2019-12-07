#!/usr/bin/perl
my %seq;
my $id="no";
while(<>){
	chomp;
	if(/>/){
		s/\>//g;
		$id=$_;
		$seq{$id}="";
	}else{
		s/\s//g;
		$line=uc($_);
		$seq{$id}.=$line;
	}
}
my $len=length($seq{$id});
my $num=keys %seq;
print "  $num  $len\n";
#while(my ($k,$v) = each %seq){
foreach my $key (sort keys %seq){
	my $name="$key               ";
	$name=substr($name,0,18);
	my $v=$seq{$key};
	print STDERR "length error in $key\n" if ($len ne length($v));
	print "$name  $v\n";
}

