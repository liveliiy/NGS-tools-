my $name;
while (<>){
	chomp;
	if (/^>/){
		s/>//;
		$name = $_;
	}elsif (/^M.*?\*$/){
		next;
	}else{
		print ">$name\n$_\n";
	}
}
