{-# LANGUAGE FlexibleContexts #-}

-- I import qualified so that it's clear which
-- functions are from the parsec library:
import qualified Text.Parsec as Parsec

-- I am the choice and optional error message infix operator, used later:
import Text.Parsec ((<?>))

-- Imported so we can play with applicative things later.
-- not qualified as mostly infix operators we'll be using.
import Control.Applicative

-- Get the Identity monad from here:
import Control.Monad.Identity (Identity)

-- alias parseTest for more concise usage in my examples:
parse rule text = Parsec.parse rule "(source)" text
--sumar num1 num2 = num1 + num2

parsear = parse program "define domain phs={0,1,2,3,4}; define place piensa type phs, come type phs, ten type phs; define trans empieza guard i=p && d=(p+1)%5 , termina; define arc piensa to empieza var p, ten to empieza var i, ten to empieza var d, come from empieza var p, come to termina var p, pienza from termina var p, ten from termina var i=p, ten from termina var d=(p+1)%5;define init piensa={0,1,2,3,4}, ten={0,1,2,3,4};list transitions;"


imprimir [] = ""
imprimir arreglo = head arreglo ++ ", " ++ imprimir(tail arreglo)

letra_minuscula :: Parsec.Parsec String () Char
letra_minuscula = do
    letra <- Parsec.letter
    return letra

didentifier :: Parsec.Parsec String () String

didentifier = do
  letras <- Parsec.many1 Parsec.letter
  return (letras)



coma :: Parsec.Parsec String () ()
--mySeparator = Parsec.spaces >> Parsec.char ',' >> Parsec.spaces
coma = do Parsec.spaces >> Parsec.string "," >> Parsec.spaces


puntoycoma :: Parsec.Parsec String () ()
--mySeparator = Parsec.spaces >> Parsec.char ',' >> Parsec.spaces
puntoycoma = do Parsec.spaces >> Parsec.string ";" >> Parsec.spaces


cruz :: Parsec.Parsec String () ()
--mySeparator = Parsec.spaces >> Parsec.char ',' >> Parsec.spaces
cruz = do Parsec.spaces >> Parsec.string "X" >> Parsec.spaces

numeros :: Parsec.Parsec String () String
numeros = do
  numeros <- Parsec.many1 Parsec.digit
  return (numeros)

dprod = do
  identificador1 <- didentifier
  cruz <- (Parsec.oneOf "X")
  identificador2 <- didentifier
  return (identificador1++"X"++identificador2)


setop = do
  operador <- Parsec.string "U" <|> Parsec.string "∩" <|> Parsec.string "-"
  return operador


dsetop = do
  identificador1 <- didentifier
  op <- setop
  identificador2 <- didentifier
  return (identificador1++op++identificador2)


denum = do
  corcheteAbre <- Parsec.string "{"
  valores <- Parsec.sepBy1 (Parsec.digit) coma
  corcheteCierra <- Parsec.string "}"
  return ("{"++valores++"}")


program = do
  declars <- declarations
  evalau <- evaluations
  return ("Declarations: "++imprimir declars++" Evaluations: "++imprimir evalau)

evaluations = do
  ev <- Parsec.sepBy1 evaluation puntoycoma
  return (ev)

evaluation = do
  tipo <- list <|> query <|> fire
  return (tipo)

list = do
  list <- Parsec.string "list "
  tipo <- Parsec.string "transitions" <|> Parsec.string "places"  <|> Parsec.string "arcs" <|> Parsec.string "enabled"
  final <- Parsec.string ";"
  return (list++tipo)

query = do
  is <- Parsec.string "is_enabled "
  tidentifier <- didentifier
  return (is++tidentifier)

fire = do
  fire <- Parsec.string "fire "
  tipo <- tfire <|> afire <|> ufire
  return tipo

tfire = do
  tidentifier <- Parsec.sepBy1 didentifier coma
  return (imprimir tidentifier)

afire = do
  al <- Parsec.string "all "
  cond <- trans_cond
  limit <- Parsec.string " limit "
  cant <- Parsec.many1 Parsec.digit
  return (al++cond++limit)

trans_cond = do
  tran <- Parsec.sepBy1 relop tran_cond
  return (imprimir tran)

tran_cond = do
  tidentifier <- didentifier
  reach <- Parsec.string " reach "
  guard <- guard_def
  return (tidentifier++reach++guard)

ufire = do
  unti <- Parsec.string " until "
  cond <- trans_cond
  return (unti++cond)

declarations = do
  dec <- Parsec.sepBy1 declaration puntoycoma
  return (dec)


declaration = do
  define <- Parsec.string "define "
  tipo <- domain_def <|> trans_def <|> place_def <|> arc_def <|> init_def
  return (tipo)



domain_def = do
  domain <- Parsec.string "domain "
  identificador <- didentifier
  igual <- Parsec.string "="
  tipo <- denum <|> dprod <|> dsetop
  return ("Dominio: "++domain++identificador++igual++tipo++" ----------------------------------- ")

trans_def = do
  trans <- Parsec.string "trans "
  tidentifier <- didentifier
  espacio <- Parsec.string " "
  guard <-Parsec.sepBy guarda coma
  return ("Transiciones: "++tidentifier++" "++imprimir guard++" ------------------------------------ ")

place_def = do
  place <- Parsec.string "place "
  plazas <- Parsec.sepBy1 places coma
  return ("Plazas: "++imprimir plazas++" ----------------------------------- ")

arc_def = do
  arc <- Parsec.string "arc "
  arcos <- Parsec.sepBy1 arcs coma
  return ("Arcos: "++imprimir arcos++" ----------------------------------- ")
init_def = do
  ini <- Parsec.string "init "
  assign <- Parsec.sepBy1 place_assign coma
  final <- Parsec.string ";"
  return (imprimir assign++" ----------------------------------- ")

place_assign = do
  pidentifier <- didentifier
  igual <- Parsec.string "="
  abroCor <- Parsec.string "{"
  values <- Parsec.sepBy1 extdvalue coma
  cierroCor <- Parsec.string "}"
  return (pidentifier++igual++abroCor++imprimir values++cierroCor)



arcs = do
  pidentifier <- didentifier
  espacio <- Parsec.string " "
  tipo <- input_arc <|> output_arc
  var <- Parsec.string " var "
  identifier <- didentifier
  cond <- arc_cond <|> Parsec.string ""
  return (pidentifier++" "++tipo++var++identifier++cond)

input_arc = do
  to <- Parsec.string "to "
  tidentifier <- didentifier
  return (to++tidentifier)

output_arc = do
  from <- Parsec.string "from "
  tidentifier <- didentifier
  return (from++tidentifier)


places = do
  pidentifier <- didentifier
  tipo <- Parsec.string " type "
  tidentifier <- didentifier
  return (pidentifier++tipo++tidentifier)

guarda = do
  valor <- guard_def <|> simple_guard_def
  return valor

simple_guard_def = do
  tidentifier <- didentifier
  return (tidentifier)


guard_def = do
  guard <- Parsec.string "guard "
  def <- var_cond
  espacio <- Parsec.string " "
  siguientes <-continuacion_guar_def
  return (guard++def++espacio++siguientes)

continuacion_guar_def = do
  op <- relop
  espacio <- Parsec.string " "
  def <- var_cond
  return (op++espacio++def)

boolop = do
  operador <- Parsec.string "=" <|> Parsec.string "!=" <|> Parsec.string "<" <|> Parsec.string ">"
  return operador

relop = do
  ope <- Parsec.string "&&" <|> Parsec.string "||"
  return ope

mathop = do
  op <- Parsec.string "+" <|> Parsec.string "-" <|> Parsec.string "*" <|> Parsec.string "/" <|> Parsec.string "%"
  return op



condexpr = do
  eef <- Parsec.string "if"
  abroPar <- Parsec.string "("
  var <- var_cond
  cierroPar <- Parsec.string ")"
  den <- Parsec.string "then "
  math <- mathexpr
  els <- Parsec.string "else "
  math2 <- mathexpr
  return (eef++abroPar++var++cierroPar++den++math++els++math2)

var_cond = do
  videntifier <- didentifier
  arc <- arc_cond
  return (videntifier++arc)

arc_cond = do
  op <- boolop
  value <- extdvalue
  return (op++value)

extdvalue = do
  --MAAAAAAAL
  value <- exprvalue <|> Parsec.sepBy Parsec.digit cruz
  return value


mathexprRegular = do
  op <- mathop
  segundo <- unary
  return (op++segundo)

mathexpr = do
  primero <- unary
  siguiente <- mathexprRegular <|> Parsec.string ""
  return (primero++siguiente)

exprvalue = do
  value <- condexpr <|> mathexpr
  return (value)

unary = do
  valor <- primary
  return valor


primary = do
  valor <-  mathexprEnPrimary <|> didentifier <|> (Parsec.many Parsec.digit)
  return valor

mathexprEnPrimary = do
  abroPar <- Parsec.string "("
  expr <- mathexpr
  cierroPar <- Parsec.string ")"
  return (abroPar++expr++cierroPar)
