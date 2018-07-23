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
#$::RD_TRACE  = 1;      # if defined, also trace parsers' behaviour
#$Parse::RecDescent::skip = '[ \r]+';

$parser = Parse::RecDescent->new(q(
  startrule :declarations evaluations

  declarations: declaration(s /;/)
  declaration:"define" ("domain" domain_def|"trans" transition_def|"arc" arc_def|"place" place_def|"init" init_def ";")
  domain_def:didentifier "=" (denum|dprod|dsetop)
  didentifier:/(([a-z]+\d*)(?=[^\d]|\s))/
  espacio: /\s+/
  letter:/[a-z]/
  digit:/\d/
  transition_def: (tidentifier ("guard" guard_def)(s?))(s /,/)
  guard_inter: "guard" guard_def
  guard_def: var_cond (relop guard_def)(s?) | "("guard_def")"
  tidentifier: didentifier
  arc_def: ((input_arc | output_arc) "var" videntifier arc_cond(?))(s /,/)
  input_arc: pidentifier "to" tidentifier
  output_arc: pidentifier "from" tidentifier
  place_def: (pidentifier "type" didentifier)(s /,/)
  pidentifier: didentifier
  init_def:place_assign(s /,/)
  place_assign: pidentifier "=" "{"extdvalue(s /,/)"}"
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
  arc_cond: boolop extdvalue
  boolop: "="|"!="|"<"|">"
  extdvalue: exprvalue | exprvalue 'X' exprvalue
  exprvalue: condexpr | mathexpr
  condexpr: "if ("var_cond") then" mathexpr "else" mathexpr
  mathexpr:(unary (mathop unary)(s?))
  mathop: "+" | "-" | "*" | "/" | "%"
  unary:"(- "primary")" | primary
  primary: integer | didentifier |"("mathexpr")"
  evaluations: evaluation(s /;/)
  evaluation: list | query | fire
  list: plist | tlist | alist | elist
  plist: "list places"
  tlist: "list transitions"
  alist: "list arcs"
  elist: "list enabled"
  query: equery
  equery: "is_enabled" tidentifier
  fire: tfire | afire | ufire
  tfire: "fire" tidentifier(s /,/)
  afire: ("fire all" (integer "times")(?))
  ufire: ("fire until" trans_cond ("limit" integer)(?))
  trans_cond: (tran_cond (relop tran_cond)(s?))
  tran_cond: (tidentifier ("not")(?) "reach" guard_def)

));

# Test it on sample data
$prueba ="define domain phs = {0,1,2,3,4};
define place piensa type phs, come type phs, ten type phs; define trans empieza guard i=p && d=(p+1)%5 , termina;
define arc piensa to empieza var p, ten to empieza var i,
ten to empieza var d,
come from empieza var p,
come to termina var p,
pienza from termina var p,
ten from termina var i = p,
ten from termina var d = (p+1)%5;
define init piensa={0,1,2,3,4}, ten={0,1,2,3,4}; list transitions;";
#print "Valido" if $prueba =~ /c*|a*/;
#print $parser->startrule;
defined $parser->startrule($prueba) or die "didn't match \n";
