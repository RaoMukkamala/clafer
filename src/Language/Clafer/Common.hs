{-# LANGUAGE DeriveDataTypeable, RankNTypes, KindSignatures, FlexibleContexts #-}
{-
 Copyright (C) 2012-2014 Kacper Bak, Jimmy Liang <http://gsd.uwaterloo.ca>

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
module Language.Clafer.Common where

import Data.Tree
import Data.Maybe
import Data.Char
import Data.List
import qualified Data.Map as Map

import Language.Clafer.Front.Absclafer
import Language.Clafer.Intermediate.Intclafer

-- -----------------------------------------------------------------------------
-- basic functions shared by desugarer, analyzer and code generator
type Result = String

transIdent :: PosIdent -> String
transIdent (PosIdent (_, str)) = str

mkIdent :: String -> PosIdent
mkIdent str = PosIdent ((0, 0), str)

mkInteger :: Read a => PosInteger -> a
mkInteger (PosInteger (_, n)) = read n

type Ident = PosIdent

getSuper :: IClafer -> String
getSuper = getSuperId._supers._super

getSuperNoArr :: IClafer -> String

getSuperNoArr clafer
  | _isOverlapping $ _super clafer = "clafer"
  | otherwise                    = getSuper clafer

getSuperId :: [PExp] -> String
getSuperId = _sident . Language.Clafer.Intermediate.Intclafer._exp . head

isEqClaferId :: String -> IClafer -> Bool
isEqClaferId = flip $ (==)._uid

idToPExp :: String -> Span -> String -> String -> Bool -> PExp
idToPExp pid' pos modids id' isTop' = PExp (Just $ TClafer [id']) pid' pos (IClaferId modids id' isTop' Nothing)

mkLClaferId :: CName -> Bool -> ClaferBinding -> IExp
mkLClaferId = IClaferId ""

mkPLClaferId :: CName -> Bool -> ClaferBinding -> PExp
mkPLClaferId id' isTop' bind' = pExpDefPidPos $ mkLClaferId id' isTop' bind'

pExpDefPidPos :: IExp -> PExp
pExpDefPidPos = pExpDefPid noSpan

pExpDefPid :: Span -> IExp -> PExp
pExpDefPid = pExpDef ""

pExpDef :: String -> Span -> IExp -> PExp
pExpDef = PExp Nothing

isParent :: PExp -> Bool
isParent (PExp _ _ _ (IClaferId _ id' _ _)) = id' == parentIdent
isParent _ = False

isClaferName :: PExp -> Bool
isClaferName (PExp _ _ _ (IClaferId _ id' _ _)) =
  id' `notElem` (specialNames ++ primitiveTypes)
isClaferName _ = False

isClaferName' :: PExp -> Bool
isClaferName' (PExp _ _ _ (IClaferId _ _ _ _)) = True
isClaferName' _ = False

getClaferName :: PExp -> String
getClaferName (PExp _ _ _ (IClaferId _ id' _ _)) = id'
getClaferName _ = ""

-- -----------------------------------------------------------------------------
-- conversions
elemToClafer :: IElement -> Maybe IClafer
elemToClafer x = case x of
  IEClafer clafer  -> Just clafer
  _  -> Nothing

toClafers :: [IElement] -> [IClafer]
toClafers = mapMaybe elemToClafer

-- -----------------------------------------------------------------------------
-- finds hierarchy and transforms each element
mapHierarchy :: (IClafer -> b)
                -> (IClafer -> String)
                -> [IClafer]
                -> IClafer
                -> [b]
mapHierarchy f sf = (map f.).(findHierarchy sf)


-- returns inheritance hierarchy of a clafer

findHierarchy :: (IClafer -> String)
                            -> [IClafer]
                            -> IClafer
                            -> [IClafer]
findHierarchy sFun clafers clafer
  | sFun clafer == "clafer"      = [clafer]
  | otherwise                    = if clafer `elem` superClafers
                                   then error $ "Inheritance hierarchy contains a cycle: line " ++ (show $ _cinPos clafer)
                                   else clafer : superClafers
  where
  superClafers = unfoldr (\c -> find (isEqClaferId $ sFun c) clafers >>=
                          Just . (apply id)) clafer

-- -----------------------------------------------------------------------------
-- generic functions

apply :: forall t t1. (t -> t1) -> t -> (t, t1)
apply f x = (x, f x)

-- lists all nodes of a tree (BFS). Take a function to extract subforest
bfs :: forall b b1. (b1 -> (b, [b1])) -> [b1] -> [b]
bfs toNode seed = map rootLabel $ concat $ takeWhile (not.null) $
  iterate (concatMap subForest) $ unfoldForest toNode seed


toNodeShallow :: IClafer -> (IClafer, [IClafer])
toNodeShallow = apply (getSubclafers._elements)


getSubclafers :: [IElement] -> [IClafer]
getSubclafers = mapMaybe elemToClafer


bfsClafers :: [IClafer] -> [IClafer]
bfsClafers clafers = bfs toNodeShallow clafers

lurry :: forall t t1. ([t1] -> t) -> t1 -> t1 -> t
lurry f x y = f [x,y]

fst3 :: forall t t1 t2. (t, t1, t2) -> t
fst3 (a, _, _) = a
snd3 :: forall t t1 t2. (t, t1, t2) -> t1
snd3 (_, b, _) = b
trd3 :: forall t t1 t2. (t, t1, t2) -> t2
trd3 (_, _, c) = c


toTriple :: forall t t1 t2. t -> (t1, t2) -> (t, t1, t2)
toTriple a (b,c) = (a, b, c)

toMTriple :: forall t t1 t2. t -> (t1, t2) -> Maybe (t, t1, t2)
toMTriple a (b,c) = Just (a, b, c)

-- unary operators
iNot :: String
iNot          = "!"

iG :: String
iG          = "G"

iF :: String
iF          = "F"

iX :: String
iX          = "X"

iCSet :: String
iCSet         = "#"

iMin :: String
iMin          = "-"

iGMax :: String
iGMax         = "max"

iGMin :: String
iGMin         = "min"

iSumSet :: String
iSumSet       = "sum"

unOps :: [String]
unOps = [iNot, iCSet, iMin, iGMax, iGMin, iSumSet, iX, iF, iG]

-- binary operators
iIff :: String
iIff          = "<=>"

iImpl :: String
iImpl         = "=>"

iOr :: String
iOr           = "||"

iXor :: String
iXor          = "xor"

iAnd :: String
iAnd          = "&&"

iU :: String
iU          = "U"

iW :: String
iW          = "W"

logBinOps :: [String]
logBinOps = [iIff, iImpl, iOr, iXor, iAnd, iU, iW]

iLt :: String
iLt           = "<"

iGt :: String
iGt           = ">"

iEq :: String
iEq           = "="

iLte :: String
iLte          = "<="

iGte :: String
iGte          = ">="

iNeq :: String
iNeq          = "!="

iIn :: String
iIn           = "in"

iNin :: String
iNin          = "not in"

ltlOps :: [String]
ltlOps = [iW, iU, iX, iG, iF]

ltlBinOps :: [String]
ltlBinOps = [iW, iU]

ltlUnOps :: [String]
ltlUnOps = [iX, iG, iF]

relGenBinOps :: [String]
relGenBinOps = [iLt, iGt, iEq, iLte, iGte, iNeq]

relSetBinOps :: [String]
relSetBinOps = [iIn, iNin]

relBinOps :: [String]
relBinOps = relGenBinOps ++ relSetBinOps

iPlus :: String
iPlus         = "+"

iSub :: String
iSub          = "-"

iMul :: String
iMul          = "*"

iDiv :: String
iDiv          = "/"

iSumSet' :: String
iSumSet'      = "sum'"

arithBinOps :: [String]
arithBinOps = [iPlus, iSub, iMul, iDiv, iSumSet']

iUnion :: String
iUnion        = "++"

iDifference :: String
iDifference   = "--"

iIntersection :: String
iIntersection = "&"

iDomain :: String
iDomain       = "<:"

iRange :: String
iRange        = ":>"

iJoin :: String
iJoin         = "."

setBinOps :: [String]
setBinOps = [iUnion, iDifference, iIntersection, iDomain, iRange, iJoin]

binOps :: [String]
binOps = logBinOps ++ relBinOps ++ arithBinOps ++ setBinOps

-- ternary operators
iIfThenElse :: String
iIfThenElse   = "ifthenelse"

mkIFunExp :: String -> [IExp] -> IExp
mkIFunExp _ (x:[]) = x
mkIFunExp op' xs = foldl1 (\x y -> IFunExp op' $ map (PExp (Just $ TClafer []) "" noSpan) [x,y]) xs

toLowerS :: String -> String
toLowerS "" = ""
toLowerS (s:ss) = toLower s : ss

-- -----------------------------------------------------------------------------
-- Constants

rootIdent :: String
rootIdent = "root"

thisIdent :: String
thisIdent = "this"

parentIdent :: String
parentIdent = "parent"

refIdent :: String
refIdent = "ref"

childrenIdent :: String
childrenIdent = "children"

specialNames :: [String]
specialNames = [thisIdent, parentIdent, refIdent, rootIdent, childrenIdent]

isSpecial :: String -> Bool
isSpecial = flip elem specialNames

stringType :: String
stringType = "string"

intType :: String
intType = "int"

integerType :: String
integerType = "integer"

realType :: String
realType = "real"

booleanType :: String
booleanType = "boolean"

baseClafer :: String
baseClafer = "clafer"

modSep :: String
modSep = "\\"

primitiveTypes :: [String]
primitiveTypes = [stringType, intType, integerType, realType]

isPrimitive :: String -> Bool
isPrimitive = flip elem primitiveTypes

-- | reserved keywords which cannot be used as clafer identifiers
keywordIdents :: [String]
keywordIdents =
  specialNames ++
  primitiveTypes ++
  [ iGMax, iGMin, iSumSet ] ++ -- unary operators
  [ iXor, iIn ] ++ -- binary operators
  [ "if", "then", "else" ] ++ -- ternary operators
  [ "no", "not", "some", "one", "all", "disj" ] ++ -- quantifiers
  [ "opt", "mux", "or", "lone" ] ++ -- group cardinalities
  [ "abstract", "enum" ] -- keywords

data GEnv = GEnv {
  identCountMap :: Map.Map String Int,
  expCount :: Int,
  stable :: Map.Map UID [[UID]], -- super clafer names of a given clafer
  sClafers ::[IClafer] -- all clafers (no going through references)
  } deriving (Eq, Show)

voidf :: Monad m => m t -> m ()
voidf f = do
  _ <- f
  return ()
