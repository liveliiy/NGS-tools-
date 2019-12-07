#!/usr/bin/perl
print "ID\tLength\tAbiOrNs\n";
while (<>) {
    chomp;
    # handle prev seq
    if (/\>/) {
      if ($currentSeq) {
	my $abistes = $currentLen - $currentStopCnt;
        print "$currentSeq\t$currentLen\t$abistes\n";
	$currentSeq = $_;
        $currentLen = 0;
        $currentStopCnt = 0;
      }else{
	$currentSeq = $_;
	}
    } else {
      $_ = uc($_);
      $_ =~ s/\s//g;
      $currentLen += length($_);
      $currentStopCnt += tr/[ACGT]//; # this removes the stop codon from $_
    }
    #$currentSeq .= "$_\n";
}
if ($currentSeq) {
	my $abistes = $currentLen - $currentStopCnt;
        print "$currentSeq\t$currentLen\t$abistes\n";
}

