#!/usr/bin/perl

@animals = qw(dog cat fish parrot hamster);
@sorted = reverse sort @animals;
print "I have the following pets: @sorted\n";
$l1=join(' ',@animals);
print "$l1\n"; 
@l2=split(' ',$l1);
foreach $l (@l2){
   print $l."kk";
}
print "\n";
##print "con split: @l2\n";

@primes = (2, 3, 5, 7, 11, 13, 17, 19);
@small =  map {$_ < 10 ? print $_:undef } @primes;
print "llamada a sub \n";

sub pp {         # Like pass by reference
    my ($n,$m)=@_;
#   $n =$_[0];
#   $m =$_[1];
    $n=123 unless defined $n;
    $m=88  unless defined $m; 
    return  $n + $m;  # Modify first argument
}

print pp(undef ,9) ." \n";

