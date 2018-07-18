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
$::RD_ERRORS = 1; #Parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings- warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.
$parser = Parse::RecDescent->new(q(
  startrule :declarations

  declarations: declaration(s)
  declaration:"define" ("domain" domain_def|"trans" transition_def|"arc" arc_def|"place" place_def|"init" init_def) ';'
  domain_def:didentifier "=" (denum|dprod|dsetop)
  didentifier:letter letter(s?)|digit(s?)
  letter:/\w/
  digit:/\d/
  transition_def: (tidentifier guard_inter(s?))(s /,/)
  guard_inter: "guard" guard_def
  guard_def: var_cond
  tidentifier: didentifier
  arc_def: 'a'
  place_def:'p'
  init_def:'i'
  denum:"{"dvalue(s /,/)"}"
  dprod:didentifier(2 /X/)
  dsetop: didentifier setop didentifier
  setop: "U" | "∩" | "-"
  evaluations:evaluation(s)
  evaluation: /\d+/
  dvalue:string|integer
  string:cap_letter(s)
  integer:digit(s)
  cap_letter:/[A-Z]/
  var_cond: videntifier arc_cond
  videntifier: didentifier
  relop: "&&" | "||"
  arc_cond: boolop
  boolop: "boolop"
  extdvalue: "x"
  exprvalue: 'ex'

));

# Test it on sample data
$prueba =<>;
#print "Valido" if $prueba =~ /c*|a*/;
#print $parser->startrule;
defined $parser->startrule($prueba) or die "didn't match \n";
