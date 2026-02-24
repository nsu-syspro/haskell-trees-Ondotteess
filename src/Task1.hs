{-# OPTIONS_GHC -Wall #-}
-- The above pragma enables all warnings

module Task1 where

-- Explicit import of Prelude to hide functions
-- that are not supposed to be used in this assignment
import Prelude hiding (foldl, foldr)

-- * Type definitions

-- | Binary tree
data Tree a = Leaf | Branch a (Tree a) (Tree a)
  deriving Show

-- | Forest (i.e. list of 'Tree's)
type Forest a = [Tree a]

-- | Tree traversal order
data Order = PreOrder | InOrder | PostOrder
  deriving Show

-- * Function definitions

-- | Returns values of given 'Tree' in specified 'Order' with optional leaf value
--
-- Usage example:
--
-- >>> torder PreOrder  (Just '.') (Branch 'A' Leaf (Branch 'B' Leaf Leaf))
-- "A.B.."
-- >>> torder InOrder   (Just '.') (Branch 'A' Leaf (Branch 'B' Leaf Leaf))
-- ".A.B."
-- >>> torder PostOrder (Just '.') (Branch 'A' Leaf (Branch 'B' Leaf Leaf))
-- "...BA"
--
torder :: Order    -- ^ Order of resulting traversal
       -> Maybe a  -- ^ Optional leaf value
       -> Tree a   -- ^ Tree to traverse
       -> [a]      -- ^ List of values in specified order
torder ord leafVal tree =
  case tree of
    Leaf ->
      case leafVal of
        Nothing -> []
        Just x  -> [x]
    Branch x l r ->
      case ord of
        PreOrder  -> x : (torder PreOrder  leafVal l ++ torder PreOrder  leafVal r)
        InOrder   ->     torder InOrder   leafVal l ++ (x : torder InOrder   leafVal r)
        PostOrder ->     torder PostOrder leafVal l ++ torder PostOrder leafVal r ++ [x]

-- | Returns values of given 'Forest' separated by optional separator
-- where each 'Tree' is traversed in specified 'Order' with optional leaf value
--
-- Usage example:
--
-- >>> forder PreOrder  (Just '|') (Just '.') [Leaf, Branch 'C' Leaf Leaf, Branch 'A' Leaf (Branch 'B' Leaf Leaf)]
-- ".|C..|A.B.."
-- >>> forder InOrder   (Just '|') (Just '.') [Leaf, Branch 'C' Leaf Leaf, Branch 'A' Leaf (Branch 'B' Leaf Leaf)]
-- ".|.C.|.A.B."
-- >>> forder PostOrder (Just '|') (Just '.') [Leaf, Branch 'C' Leaf Leaf, Branch 'A' Leaf (Branch 'B' Leaf Leaf)]
-- ".|..C|...BA"
--
forder :: Order     -- ^ Order of tree traversal
       -> Maybe a   -- ^ Optional separator between resulting tree orders
       -> Maybe a   -- ^ Optional leaf value
       -> Forest a  -- ^ List of trees to traverse
       -> [a]       -- ^ List of values in specified tree order
forder ord sep leafVal forest = go forest
  where
    go []       = []
    go [t]      = torder ord leafVal t
    go (t : ts) =
      let here = torder ord leafVal t
          rest = go ts
      in case sep of
           Nothing -> here ++ rest
           Just s  -> here ++ [s] ++ rest