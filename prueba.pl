#!/usr/bin/perl


use RecDescent;

# $grammar = q(
#   startrule: "c"(s)
#
# );
#
# $parser = new Parse::RecDescent($grammar);


# Create and compile the source file

$parser = Parse::RecDescent->new(q(
  startrule :declarations



  declarations: declaration(s)
  declaration:"define" ("domain" domain_def|"trans" transition_def|"arc" arc_def|"place" place_def|"init" init_def) ';'
  domain_def: didentifier "=" (denum|dprod|dsetop)
  didentifier:letter(letter(s?)|digit(s?))
  letter:/\w/
  digit:/\d/
  transition_def: 't'
  arc_def: 'a'
  place_def:'p'
  init_def:'i'
  denum:"{"dvalue(s /,/)"}"
  dprod:'2'
  dsetop:'3'
  evaluations:evaluation(s)
  evaluation: /\d+/
  dvalue:string|integer
  string:cap_letter(s)
  integer:digit(s)
  cap_letter:/[A-Z]/
));


# Test it on sample data
$prueba =<>;
#print "Valido" if $prueba =~ /c*|a*/;
#print $parser->startrule;
defined $parser->startrule($prueba) or die "didn't match";
