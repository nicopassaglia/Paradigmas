#!/usr/bin/perl
use RecDescent;

# $grammar = q(
#   startrule: "c"(s)
#
# );
#
# $parser = new Parse::RecDescent($grammar);
#tidentifier guard_inter(s) transition_def(s? /,/)

# Create and compile the source file

$parser = Parse::RecDescent->new(q(
  startrule : identificador(2 /X/)
  identificador: letter(letter|digit)
  letter:/\w/
  digit:/\d/

));

# Test it on sample data
$prueba =<>;
#print "Valido" if $prueba =~ /c*|a*/;
#print $parser->startrule;
defined $parser->startrule($prueba) or die "didn't match \n";
