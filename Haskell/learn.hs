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
