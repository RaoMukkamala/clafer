{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
module Language.Clafer.Front.Absclafer where

-- Haskell module generated by the BNF converter


import Data.Data (Data,Typeable)
import GHC.Generics (Generic)
data Pos = Pos Integer Integer  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)
noPos :: Pos
noPos = Pos 0 0

data Span = Span Pos Pos deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)
noSpan :: Span
noSpan = Span noPos noPos

class Spannable n where
  getSpan :: n -> Span

instance Spannable n => Spannable [n] where
  getSpan (x:xs) = foldr (\item acc -> getSpan item >- acc ) (getSpan x) xs
  getSpan [] = noSpan

(>-) :: Span -> Span -> Span
(>-) (Span (Pos 0 0) (Pos 0 0)) s = s
(>-) r (Span (Pos 0 0) (Pos 0 0)) = r
(>-) (Span m _) (Span _ p) = Span m p
(>-) _ _ = error "Function '>-' was not given (Span (Pos 0 0) (Pos 0 0)) as one of it's argumented expected one argument of (Span (Pos 0 0) (Pos 0 0))"

len :: [a] -> Integer
len = toInteger . length

newtype PosInteger = PosInteger ((Int,Int),String) deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)
newtype PosDouble = PosDouble ((Int,Int),String) deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)
newtype PosString = PosString ((Int,Int),String) deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)
newtype PosIdent = PosIdent ((Int,Int),String) deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)
data Module =
   Module Span [Declaration]
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Declaration =
   EnumDecl Span PosIdent [EnumId]
 | ElementDecl Span Element
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Clafer =
   Clafer Span Abstract GCard PosIdent Super Card Init Elements
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Constraint =
   Constraint Span [Exp]
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data SoftConstraint =
   SoftConstraint Span [Exp]
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Goal =
   Goal Span [Exp]
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Abstract =
   AbstractEmpty Span
 | Abstract Span
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Elements =
   ElementsEmpty Span
 | ElementsList Span [Element]
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Element =
   Subclafer Span Clafer
 | ClaferUse Span Name Card Elements
 | Subconstraint Span Constraint
 | Subgoal Span Goal
 | Subsoftconstraint Span SoftConstraint
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Super =
   SuperEmpty Span
 | SuperSome Span SuperHow SetExp
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data SuperHow =
   SuperColon Span
 | SuperArrow Span
 | SuperMArrow Span
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Init =
   InitEmpty Span
 | InitSome Span InitHow Exp
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data InitHow =
   InitHow_1 Span
 | InitHow_2 Span
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data GCard =
   GCardEmpty Span
 | GCardXor Span
 | GCardOr Span
 | GCardMux Span
 | GCardOpt Span
 | GCardInterval Span NCard
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Card =
   CardEmpty Span
 | CardLone Span
 | CardSome Span
 | CardAny Span
 | CardNum Span PosInteger
 | CardInterval Span NCard
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data NCard =
   NCard Span PosInteger ExInteger
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data ExInteger =
   ExIntegerAst Span
 | ExIntegerNum Span PosInteger
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Name =
   Path Span [ModId]
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Exp =
   DeclAllDisj Span Decl Exp
 | DeclAll Span Decl Exp
 | DeclQuantDisj Span Quant Decl Exp
 | DeclQuant Span Quant Decl Exp
 | EGMax Span Exp
 | EGMin Span Exp
 | EIff Span Exp Exp
 | EImplies Span Exp Exp
 | EOr Span Exp Exp
 | EXor Span Exp Exp
 | EAnd Span Exp Exp
 | ENeg Span Exp
 | ELt Span Exp Exp
 | EGt Span Exp Exp
 | EEq Span Exp Exp
 | ELte Span Exp Exp
 | EGte Span Exp Exp
 | ENeq Span Exp Exp
 | EIn Span Exp Exp
 | ENin Span Exp Exp
 | QuantExp Span Quant Exp
 | EAdd Span Exp Exp
 | ESub Span Exp Exp
 | EMul Span Exp Exp
 | EDiv Span Exp Exp
 | ESumSetExp Span Exp
 | ECSetExp Span Exp
 | EMinExp Span Exp
 | EImpliesElse Span Exp Exp Exp
 | EInt Span PosInteger
 | EDouble Span PosDouble
 | EStr Span PosString
 | ESetExp Span SetExp
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data SetExp =
   Union Span SetExp SetExp
 | UnionCom Span SetExp SetExp
 | Difference Span SetExp SetExp
 | Intersection Span SetExp SetExp
 | Domain Span SetExp SetExp
 | Range Span SetExp SetExp
 | Join Span SetExp SetExp
 | ClaferId Span Name
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Decl =
   Decl Span [LocId] SetExp
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data Quant =
   QuantNo Span
 | QuantNot Span
 | QuantLone Span
 | QuantOne Span
 | QuantSome Span
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data EnumId =
   EnumIdIdent Span PosIdent
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data ModId =
   ModIdIdent Span PosIdent
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

data LocId =
   LocIdIdent Span PosIdent
  deriving (Eq,Ord,Show,Read,Data,Typeable,Generic)

instance Spannable Module where
  getSpan ( Module s _ ) = s

instance Spannable Declaration where
  getSpan ( EnumDecl s _ _ ) = s
  getSpan ( ElementDecl s _ ) = s

instance Spannable Clafer where
  getSpan ( Clafer s _ _ _ _ _ _ _ ) = s

instance Spannable Constraint where
  getSpan ( Constraint s _ ) = s

instance Spannable SoftConstraint where
  getSpan ( SoftConstraint s _ ) = s

instance Spannable Goal where
  getSpan ( Goal s _ ) = s

instance Spannable Abstract where
  getSpan ( AbstractEmpty s ) = s
  getSpan ( Abstract s ) = s

instance Spannable Elements where
  getSpan ( ElementsEmpty s ) = s
  getSpan ( ElementsList s _ ) = s

instance Spannable Element where
  getSpan ( Subclafer s _ ) = s
  getSpan ( ClaferUse s _ _ _ ) = s
  getSpan ( Subconstraint s _ ) = s
  getSpan ( Subgoal s _ ) = s
  getSpan ( Subsoftconstraint s _ ) = s

instance Spannable Super where
  getSpan ( SuperEmpty s ) = s
  getSpan ( SuperSome s _ _ ) = s

instance Spannable SuperHow where
  getSpan ( SuperColon s ) = s
  getSpan ( SuperArrow s ) = s
  getSpan ( SuperMArrow s ) = s

instance Spannable Init where
  getSpan ( InitEmpty s ) = s
  getSpan ( InitSome s _ _ ) = s

instance Spannable InitHow where
  getSpan ( InitHow_1 s ) = s
  getSpan ( InitHow_2 s ) = s

instance Spannable GCard where
  getSpan ( GCardEmpty s ) = s
  getSpan ( GCardXor s ) = s
  getSpan ( GCardOr s ) = s
  getSpan ( GCardMux s ) = s
  getSpan ( GCardOpt s ) = s
  getSpan ( GCardInterval s _ ) = s

instance Spannable Card where
  getSpan ( CardEmpty s ) = s
  getSpan ( CardLone s ) = s
  getSpan ( CardSome s ) = s
  getSpan ( CardAny s ) = s
  getSpan ( CardNum s _ ) = s
  getSpan ( CardInterval s _ ) = s

instance Spannable NCard where
  getSpan ( NCard s _ _ ) = s

instance Spannable ExInteger where
  getSpan ( ExIntegerAst s ) = s
  getSpan ( ExIntegerNum s _ ) = s

instance Spannable Name where
  getSpan ( Path s _ ) = s

instance Spannable Exp where
  getSpan ( DeclAllDisj s _ _ ) = s
  getSpan ( DeclAll s _ _ ) = s
  getSpan ( DeclQuantDisj s _ _ _ ) = s
  getSpan ( DeclQuant s _ _ _ ) = s
  getSpan ( EGMax s _ ) = s
  getSpan ( EGMin s _ ) = s
  getSpan ( EIff s _ _ ) = s
  getSpan ( EImplies s _ _ ) = s
  getSpan ( EOr s _ _ ) = s
  getSpan ( EXor s _ _ ) = s
  getSpan ( EAnd s _ _ ) = s
  getSpan ( ENeg s _ ) = s
  getSpan ( ELt s _ _ ) = s
  getSpan ( EGt s _ _ ) = s
  getSpan ( EEq s _ _ ) = s
  getSpan ( ELte s _ _ ) = s
  getSpan ( EGte s _ _ ) = s
  getSpan ( ENeq s _ _ ) = s
  getSpan ( EIn s _ _ ) = s
  getSpan ( ENin s _ _ ) = s
  getSpan ( QuantExp s _ _ ) = s
  getSpan ( EAdd s _ _ ) = s
  getSpan ( ESub s _ _ ) = s
  getSpan ( EMul s _ _ ) = s
  getSpan ( EDiv s _ _ ) = s
  getSpan ( ESumSetExp s _ ) = s
  getSpan ( ECSetExp s _ ) = s
  getSpan ( EMinExp s _ ) = s
  getSpan ( EImpliesElse s _ _ _ ) = s
  getSpan ( EInt s _ ) = s
  getSpan ( EDouble s _ ) = s
  getSpan ( EStr s _ ) = s
  getSpan ( ESetExp s _ ) = s

instance Spannable SetExp where
  getSpan ( Union s _ _ ) = s
  getSpan ( UnionCom s _ _ ) = s
  getSpan ( Difference s _ _ ) = s
  getSpan ( Intersection s _ _ ) = s
  getSpan ( Domain s _ _ ) = s
  getSpan ( Range s _ _ ) = s
  getSpan ( Join s _ _ ) = s
  getSpan ( ClaferId s _ ) = s

instance Spannable Decl where
  getSpan ( Decl s _ _ ) = s

instance Spannable Quant where
  getSpan ( QuantNo s ) = s
  getSpan ( QuantNot s ) = s
  getSpan ( QuantLone s ) = s
  getSpan ( QuantOne s ) = s
  getSpan ( QuantSome s ) = s

instance Spannable EnumId where
  getSpan ( EnumIdIdent s _ ) = s

instance Spannable ModId where
  getSpan ( ModIdIdent s _ ) = s

instance Spannable LocId where
  getSpan ( LocIdIdent s _ ) = s

instance Spannable PosInteger where
  getSpan (PosInteger ((c, l), lex')) =
    Span (Pos c' l') (Pos c' $ l' + len lex')
    where
      c' = toInteger c
      l' = toInteger l

instance Spannable PosDouble where
  getSpan (PosDouble ((c, l), lex')) =
    Span (Pos c' l') (Pos c' $ l' + len lex')
    where
      c' = toInteger c
      l' = toInteger l

instance Spannable PosString where
  getSpan (PosString ((c, l), lex')) =
    Span (Pos c' l') (Pos c' $ l' + len lex')
    where
      c' = toInteger c
      l' = toInteger l

instance Spannable PosIdent where
  getSpan (PosIdent ((c, l), lex')) =
    Span (Pos c' l') (Pos c' $ l' + len lex')
    where
      c' = toInteger c
      l' = toInteger l

