{-
 Copyright (C) 2012 Kacper Bak, Jimmy Liang <http://gsd.uwaterloo.ca>

 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
-}
module Language.Clafer.Intermediate.Intclafer where

import Language.Clafer.Front.Absclafer

data IType = TBoolean
           | TString
           | TInteger
           | TReal
           | TClafer [String]
  deriving (Eq,Ord,Show)

-- each file contains exactly one mode. A module is a list of declarations
data IModule = IModule {
      mName :: String,    -- always empty for now because we don't have syntax for declaring modules
      mDecls :: [IElement]
    }
  deriving (Eq,Ord,Show)

-- Clafer has a list of fields that specify its properties. Some fields, marked as (o) are for generating optimized code
data IClafer =
   IClafer {
      cinPos :: Span,         -- the position of the syntax in source code
      isAbstract :: Bool,     -- whether abstract or not (i.e., concrete)
      gcard :: Maybe IGCard,  -- group cardinality
      ident :: String,        -- name
      uid :: String,          -- (o) unique identifier
      super:: ISuper,         -- superclafers
      card :: Maybe Interval, -- clafer cardinality
      glCard :: Interval,     -- (o) global cardinality
      elements :: [IElement]  -- nested declarations
    }
  deriving (Eq,Ord,Show)

-- Clafer's subelement is either a clafer, a constraint, or a goal (objective)
-- This is a wrapper type needed to have polymorphic lists of elements
data IElement =
   IEClafer IClafer
 | IEConstraint {
      isHard :: Bool,     -- whether hard or not (soft)
      cpexp :: PExp       -- the expression
    }
 | IEGoal {
   isMaximize :: Bool,    -- whether maximize or minimize
   cpexp :: PExp          -- the expression
   }
  deriving (Eq,Ord,Show)

-- A list of superclafers.  
-- ->    -- overlaping unique (set)
-- ->>   -- overlapping non-unique (bag)
-- :     -- non overlapping (disjoint)
data ISuper =
   ISuper {
      isOverlapping :: Bool,  -- whether overlapping or disjoint with other clafers extending given list of superclafers
      supers :: [PExp]
    }
  deriving (Eq,Ord,Show)

-- Group cardinality is specified as an interval. It may also be given by a keyword.
-- xor  -- 1..1 isKeyword = True
-- 1..1 -- 1..1 isKeyword = False
data IGCard =
  IGCard {
      isKeyword :: Bool,    -- whether given by keyword: or, xor, mux
      interval :: Interval
    }
  deriving (Eq,Ord,Show)

-- (Min, Max) integer interval. -1 denotes *
type Interval = (Integer, Integer)

-- This is expression container (parent). It has meta information about an actual expression 'exp'
data PExp = PExp {
      iType :: Maybe IType,  
      pid :: String,         -- non-empy unique id for expressions with span, "" for noSpan
      inPos :: Span,         -- position in the input Clafer file
      exp :: IExp            -- the actual expression
    }
  deriving (Eq,Ord,Show)

data IExp = 
   -- quantified expression with declarations
   -- e.g., [ all x1; x2 : X | x1.ref != x2.ref ]
   IDeclPExp {quant :: IQuant, oDecls :: [IDecl], bpexp :: PExp}
   -- expression with a
   -- unary function, e.g., -1
   -- binary function, e.g., 2 + 3
   -- ternary function, e.g., if x then 4 else 5
 | IFunExp {op :: String, exps :: [PExp]}
 | IInt Integer                  -- integer number
 | IDouble Double                -- real number
 | IStr String                   -- string
 | IClaferId {                   -- clafer name
      modName :: String,         -- module name - currently not used and empty since we have no module system
      sident :: String,          -- name of the clafer being referred to
      isTop :: Bool              -- identifier refers to a top-level definition
    }
  deriving (Eq,Ord,Show)

{-
For IFunExp standard set of operators includes:
1. Unary operators:
        !          -- not (logical)
        #          -- set counting operator
        -          -- negation (arithmetic)
        max        -- maximum (created for goals)
        min        -- minimum (created for goals)
2. Binary operators:
        <=>        -- equivalence
        =>         -- implication
        ||         -- disjunction
        xor        -- exclusive or
        &&         -- conjunction
        <          -- less than
        >          -- greater than
        =          -- equality
        <=         -- less than or equal
        >=         -- greater than or equal
        !=         -- inequality
        in         -- belonging to a set/being a subset
        nin        -- not belonging to a set/not being a subset
        +          -- addition/string concatenation
        -          -- substraction
        *          -- multiplication
        /          -- division
        ++         -- set union
        --         -- set difference
        &          -- set intersection
        <:         -- domain restriction
        :>         -- range restriction
        .          -- relational join
3. Ternary operators
        ifthenelse -- if then else
-}

-- Local declaration
-- disj x1; x2 : X ++ Y
-- y1 : Y 
data IDecl =
   IDecl {
      isDisj :: Bool,     -- is disjunct
      decls :: [String],  -- a list of local names
      body :: PExp        -- set to which local names refer to
    }
  deriving (Eq,Ord,Show)

data IQuant =
   INo    -- does not exist
 | ILone  -- less than one
 | IOne   -- exactly one
 | ISome  -- at least one (i.e., exists)
 | IAll   -- for all
  deriving (Eq,Ord,Show)

type LineNo = Integer
type ColNo  = Integer
