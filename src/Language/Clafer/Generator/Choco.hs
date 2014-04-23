{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ViewPatterns #-}

-- | Generates JS representation of IR for the <https://github.com/gsdlab/chocosolver Chocosolver>.
module Language.Clafer.Generator.Choco (genCModule) where

import Control.Applicative
import Control.Monad
import Data.List
import Data.Maybe
import Data.Ord
import Prelude hiding (exp)
import Language.Clafer.ClaferArgs
import Language.Clafer.Common
import Language.Clafer.Front.Absclafer
import Language.Clafer.Intermediate.Intclafer

-- | Choco 3 code generation
genCModule :: ClaferArgs -> (IModule, GEnv) -> [(UID, Integer)] -> Result
genCModule _ (IModule{mDecls}, _) scopes =
    genScopes
    ++ "\n"
    ++ (genAbstractClafer =<< abstractClafers)
    ++ (genConcreteClafer =<< concreteClafers)
    ++ (genRefClafer =<< clafers)
    ++ (genTopConstraint =<< mDecls)
    ++ (genConstraint =<< clafers)
    ++ (genGoal =<< mDecls)
    where
    root :: IClafer
    root = IClafer Nothing noSpan False Nothing "root" "root" iSuper iRef (Just (1, 1)) (0, 0) mDecls
    iSuper :: ISuper
    iSuper = ISuper root TopLevel [PExp Nothing Nothing "" noSpan $ IClaferId "clafer" "clafer" True]
    iRef :: IReference
    iRef = IReference root False []

    toplevelClafers = mapMaybe iclafer mDecls
    -- The sort is so that we encounter sub clafers before super clafers when abstract clafers extend other abstract clafers
    abstractClafers = sortBy (comparing $ length . supersOf . uid) $ filter isAbstract toplevelClafers
    parentChildMap = childClafers root
    clafers = snd <$> parentChildMap
    claferUids = uid <$> clafers
    concreteClafers = filter isNotAbstract clafers
--    minusRoot = filter ((/= "root") . uid)
    
    claferWithUid u = fromMaybe (error $ "claferWithUid: \"" ++ u ++ "\" is not a clafer") $ find ((== u) . uid) clafers
    
    prims = ["int", "integer", "string", "real"]
    
    -- All abstract clafers u inherits
    supersOf :: String -> [String]
    supersOf u =
        case superOf u of
             Just su -> su : supersOf su
             Nothing -> []
        
--    superHierarchyOf u = u : supersOf u
            
    superOf u =
        case super $ claferWithUid u of
            ISuper _ TopLevel [PExp{exp = IClaferId{sident}}]
                | sident == "clafer"  -> Nothing
                | sident `elem` prims -> Nothing
                | otherwise           -> Just sident
            _ -> Nothing

{-    superWithRef u =
        case mapMaybe refOf $ supersOf u of
             r : _ -> r
             _      -> u ++ " does not inherit a ref" -}
            
    refOf u =
        case super $ claferWithUid u of
            ISuper _ _ [PExp{exp = IClaferId{sident}}] 
                | sident == "int"     -> Just "integer"
                | sident `elem` prims -> Just sident
                | otherwise           -> Nothing
            _ -> Nothing
            
    -- All clafers that inherit u
{-    subOf :: String -> [String]
    subOf u = [uid | IClafer{uid} <- clafers, Just u == superOf uid]
    subClaferOf :: String -> [IClafer]
    subClaferOf = map claferWithUid . subOf
    
    subOffsets :: [(String, String, Integer)]
    subOffsets = [(uid, sub, off) | IClafer{uid} <- clafers, let subs = subOf uid, (sub, off) <- zip subs $ offsets subs]
    
    subOffsetOf :: String -> Integer
    subOffsetOf sub = trd3 $ fromMaybe (error $ "subOffsetOf: " ++ sub) $ find ((== sub) . snd3) subOffsets
    
    offsets :: [String] -> [Integer]
    offsets = scanl (flip $ (+) . scopeOf) 0
-}        

    parentOf u = fst $ fromMaybe (error $ "parentOf: \"" ++ u ++ "\" is not a clafer") $ find ((== u) . uid . snd) parentChildMap
{-    parentClaferOf = claferWithUid . parentOf
    -- Direct childrens
    childrenOf = map uid . childrenClaferOf
    childrenClaferOf u = [c | (p, c) <- parentChildMap, p == u] 
    
    -- Indirect childrens
    indirectChildrenOf u = childrenOf =<< supersOf u
    indirectChildrenClaferOf u = childrenClaferOf =<< supersOf u  
    
    isBounded :: Interval -> Bool
    isBounded (0, -1) = False
    isBounded _       = True
-}    
    genCard :: Interval -> Maybe String
    genCard (0, -1) = Nothing
    genCard (low, -1) = return $ show low
    genCard (low, high) = return $ show low ++ ", " ++ show high
    
    
    genScopes :: Result
    genScopes =
        (if null scopeMap then "" else "scope({" ++ intercalate ", " scopeMap ++ "});\n")
        ++ "defaultScope(1);\n"
        ++ "intRange(-" ++ show (2 ^ (bitwidth - 1)) ++ ", " ++ show (2 ^ (bitwidth - 1) - 1) ++ ");\n"
        where
            scopeMap = [uid ++ ":" ++ show scope | (uid, scope) <- scopes]
                
    genConcreteClafer :: IClafer -> Result
    genConcreteClafer IClafer{uid, card = Just card, gcard = Just (IGCard _ gcard)} =
            uid ++ " = " ++ constructor ++ "(\"" ++ uid ++ "\")" ++ prop "withCard" (genCard card) ++ prop "withGroupCard" (genCard gcard) ++ prop "extending" (superOf uid) ++ ";\n"
        where
            constructor = 
                case parentOf uid of
                     "root" -> "Clafer"
                     puid   -> puid ++ ".addChild"
                     
    prop name value =
        case value of
                Just value' -> "." ++ name ++ "(" ++ value' ++ ")"
                Nothing     -> ""
                
                
    genRefClafer :: IClafer -> Result
    genRefClafer IClafer{uid} =
        case (refOf uid, uid `elem` uniqueRefs) of
             (Just target, True)  -> uid ++ ".refToUnique(" ++ genTarget target ++ ");\n"
             (Just target, False) -> uid ++ ".refTo(" ++ genTarget target ++ ");\n"
             _                    -> ""
        where
            genTarget "integer" = "Int"
            genTarget target = target
        
    genAbstractClafer :: IClafer -> Result
    genAbstractClafer IClafer{uid, card = Just _} =
        uid ++ " = Abstract(\"" ++ uid ++ "\")" ++ prop "extending" (superOf uid) ++ ";\n"  
    genAbstractClafer IClafer{uid, card = Nothing} =
        uid ++ " = Abstract(\"" ++ uid ++ "\")" ++ prop "extending" (superOf uid) ++ ";\n" 

    -- Is a uniqueness constraint? If so, return the name of unique clafer
    isUniqueConstraint :: IExp -> Maybe String
    isUniqueConstraint (IDeclPExp IAll [IDecl True [x, y] PExp{exp = IClaferId {sident}}]
        PExp{exp = IFunExp "!=" [
            PExp{exp = IFunExp "." [PExp{exp = IClaferId{sident = xident}}, PExp{exp = IClaferId{sident = "ref"}}]},
            PExp{exp = IFunExp "." [PExp{exp = IClaferId{sident = yident}}, PExp{exp = IClaferId{sident = "ref"}}]}]})
                | x == xident && y == yident = return sident
                | otherwise                  = mzero
    isUniqueConstraint  (IDeclPExp IAll [IDecl True [x, y] PExp{exp = IFunExp "." [PExp{exp = IClaferId{sident = "this"}}, PExp{exp = IClaferId {sident}}]}]
        PExp{exp = IFunExp "!=" [
            PExp{exp = IFunExp "." [PExp{exp = IClaferId{sident = xident}}, PExp{exp = IClaferId{sident = "ref"}}]},
            PExp{exp = IFunExp "." [PExp{exp = IClaferId{sident = yident}}, PExp{exp = IClaferId{sident = "ref"}}]}]})
                | x == xident && y == yident = return sident
                | otherwise                  = mzero
    isUniqueConstraint _ = mzero
    
    uniqueRefs :: [String]
    uniqueRefs = mapMaybe isUniqueConstraint $ map exp $ mapMaybe iconstraint $ mDecls ++ (clafers >>= elements)
    
    genTopConstraint :: IElement -> Result
    genTopConstraint (IEConstraint _ _ pexp)
        | isNothing $ isUniqueConstraint $ exp pexp = "Constraint(" ++ genConstraintPExp pexp ++ ");\n"
        | otherwise                                 = ""
    genTopConstraint _ = ""
    
    genConstraint :: IClafer -> Result
    genConstraint IClafer{uid, elements} =
        unlines [uid ++ ".addConstraint(" ++ genConstraintPExp c ++ ");"
            | c <- filter (isNothing . isUniqueConstraint . exp) $ mapMaybe iconstraint elements]
            
    genGoal :: IElement -> Result
    genGoal (IEGoal _ _ PExp{exp = IFunExp{op="max", exps=[expr]}})  = "max(" ++ genConstraintPExp expr ++ ");\n"
    genGoal (IEGoal _ _ PExp{exp = IFunExp{op="min", exps=[expr]}})  = "min(" ++ genConstraintPExp expr ++ ");\n"
    genGoal (IEGoal _ _ _) = error $ "Unknown objective"
    genGoal _ = ""
            
{-    nameOfType TInteger = "integer"
    nameOfType (TClafer [t]) = t
    
    namesOfType TInteger = ["integer"]
    namesOfType (TClafer ts) = ts

    getCard uid =
        case card $ claferWithUid uid of
                Just (low, -1)   -> (low, scope)
                Just (low, high) -> (low, high)
        where
            scope = scopeOf uid
    
    (l1, h1) <*> (l2, h2) = (l1 * l2, h1 * h2)
    scopeCap scope (l, h) = (min scope l, min scope h)
-}    
    rewrite :: PExp -> PExp
    -- Rearrange right joins to left joins.
    rewrite p1@PExp{iType = Just _, exp = IFunExp "." [p2, p3@PExp{exp = IFunExp "." _}]} =
        p1{exp = IFunExp "." [p3{iType = iType p4, exp = IFunExp "." [p2, p4]}, p5]}
        where
            PExp{exp = IFunExp "." [p4, p5]} = rewrite p3
    rewrite p1@PExp{exp = IFunExp{op = "-", exps = [PExp{exp = IInt i}]}} =
        -- This is so that the output looks cleaner, no other purpose since the Choco optimizer
        -- in the backend will treat the pre-rewritten expression the same.
        p1{exp = IInt (-i)}
    rewrite p = p
    
    genConstraintPExp :: PExp -> String
    genConstraintPExp = genConstraintExp . exp . rewrite
            
    genConstraintExp :: IExp -> String
    genConstraintExp (IDeclPExp quant [] body) =
        mapQuant quant ++ "(" ++ genConstraintPExp body ++ ")"
    genConstraintExp (IDeclPExp quant decls body) =
        mapQuant quant ++ "([" ++ intercalate ", " (map genDecl decls) ++ "], " ++ genConstraintPExp body ++ ")"
        where
            genDecl (IDecl isDisj locals body') =
                (if isDisj then "disjDecl" else "decl") ++ "([" ++ intercalate ", " (map genLocal locals) ++ "], " ++ genConstraintPExp body' ++ ")"
            genLocal local = 
                local ++ " = local(\"" ++ local ++ "\")"
             
    genConstraintExp (IFunExp "." [e1, PExp{exp = IClaferId{sident = "ref"}}]) =
        "joinRef(" ++ genConstraintPExp e1 ++ ")"
    genConstraintExp (IFunExp "." [e1, PExp{exp = IClaferId{sident = "parent"}}]) =
        "joinParent(" ++ genConstraintPExp e1 ++ ")"
    genConstraintExp (IFunExp "." [e1, PExp{exp = IClaferId{sident}}]) =
        "join(" ++ genConstraintPExp e1 ++ ", " ++ sident ++ ")"
    genConstraintExp (IFunExp "." [_, _]) =
        error $ "Did not rewrite all joins to left joins."
    genConstraintExp (IFunExp "-" [arg]) =
        "minus(" ++ genConstraintPExp arg ++ ")"
    genConstraintExp (IFunExp "-" [arg1, arg2]) =
        "minus(" ++ genConstraintPExp arg1 ++ ", " ++ genConstraintPExp arg2 ++ ")"
    genConstraintExp (IFunExp "sum" args')
        | [arg] <- args', PExp{exp = IFunExp{exps = [a, PExp{exp = IClaferId{sident = "ref"}}]}} <- rewrite arg =
            "sum(" ++ genConstraintPExp a ++ ")"
        | otherwise = error "Unexpected sum argument."
    genConstraintExp (IFunExp op args') =
        mapFunc op ++ "(" ++ intercalate ", " (map genConstraintPExp args') ++ ")"
    -- this is a keyword in Javascript so use "$this" instead
    genConstraintExp IClaferId{sident = "this"} = "$this()"
    genConstraintExp IClaferId{sident}
        | sident `elem` claferUids = "global(" ++ sident ++ ")"
        | otherwise                = sident
    genConstraintExp (IInt val) = "constant(" ++ show val ++ ")"
    genConstraintExp e = error $ "Unknown expression: " ++ show e
                
    mapQuant INo = "none"
    mapQuant ISome = "some"
    mapQuant IAll = "all"
    mapQuant IOne = "one"
    mapQuant ILone = "lone"
                
    mapFunc "!" = "not"
    mapFunc "#" = "card"
    mapFunc "<=>" = "ifOnlyIf"
    mapFunc "=>" = "implies"
    mapFunc "||" = "or"
    mapFunc "xor" = "xor"
    mapFunc "&&" = "and"
    mapFunc "<" = "lessThan"
    mapFunc ">" = "greaterThan"
    mapFunc "=" = "equal"
    mapFunc "<=" = "lessThanEqual"
    mapFunc ">=" = "greaterThanEqual"
    mapFunc "!=" = "notEqual"
    mapFunc "in" = "$in"
    mapFunc "nin" = "notIn"
    mapFunc "+" = "add"
    mapFunc "*" = "mul"
    mapFunc "/" = "div"
    mapFunc "++" = "union"
    mapFunc "--" = "diff"
    mapFunc "&" = "inter"
    mapFunc "=>else" = "ifThenElse"
    mapFunc op = error $ "Unknown op: " ++ op
    
{-    sidentOf u = ident $ claferWithUid u
    scopeOf "integer" = undefined
    scopeOf "int" = undefined
    scopeOf i = fromMaybe 1 $ lookup i scopes -}
    bitwidth = fromMaybe 4 $ lookup "int" scopes :: Integer
    
-- isQuant PExp{exp = IDeclPExp{}} = True
-- isQuant _ = False

isNotAbstract :: IClafer -> Bool
isNotAbstract = not . isAbstract

iclafer :: IElement -> Maybe IClafer
iclafer (IEClafer c) = Just c
iclafer _ = Nothing

iconstraint :: IElement -> Maybe PExp
iconstraint (IEConstraint _ _ pexp) = Just pexp
iconstraint _ = Nothing

childClafers :: IClafer -> [(String, IClafer)]
childClafers IClafer{uid, elements} =
    childClafers' uid =<< mapMaybe iclafer elements
    where
    childClafers' parent' c@IClafer{uid, elements} = (parent', c) : (childClafers' uid  =<< mapMaybe iclafer elements)
