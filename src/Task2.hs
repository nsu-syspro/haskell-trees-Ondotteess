{-# OPTIONS_GHC -Wall #-}
-- The above pragma enables all warnings

module Task2 where

-- Explicit import of Prelude to hide functions
-- that are not supposed to be used in this assignment
import Prelude hiding (compare, foldl, foldr, Ordering(..))

import Task1 (Tree(..))

-- * Type definitions

-- | Ordering enumeration
data Ordering = LT | EQ | GT
  deriving Show

-- | Binary comparison function indicating whether first argument is less, equal or
-- greater than the second one (returning 'LT', 'EQ' or 'GT' respectively)
type Cmp a = a -> a -> Ordering

-- * Function definitions

-- | Binary comparison function induced from `Ord` constraint
--
-- Usage example:
--
-- >>> compare 2 3
-- LT
-- >>> compare 'a' 'a'
-- EQ
-- >>> compare "Haskell" "C++"
-- GT
--
compare :: Ord a => Cmp a
compare x y
  | x < y     = LT
  | x > y     = GT
  | otherwise = EQ

-- | Conversion of list to binary search tree
-- using given comparison function
--
-- Usage example:
--
-- >>> listToBST compare [2,3,1]
-- Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf)
-- >>> listToBST compare ""
-- Leaf
--
listToBST :: Cmp a -> [a] -> Tree a
listToBST cmp = go Leaf
  where
    go t []     = t
    go t (x:xs) = go (tinsert cmp x t) xs

-- | Conversion from binary search tree to list
--
-- Resulting list will be sorted
-- if given tree is valid BST with respect
-- to some 'Cmp' comparison.
--
-- Usage example:
--
-- >>> bstToList (Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf))
-- [1,2,3]
-- >>> bstToList Leaf
-- []
--
bstToList :: Tree a -> [a]
bstToList Leaf = []
bstToList (Branch x l r) = bstToList l ++ (x : bstToList r)

-- | Tests whether given tree is a valid binary search tree
-- with respect to given comparison function
--
-- Usage example:
--
-- >>> isBST compare (Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf))
-- True
-- >>> isBST compare (Leaf :: Tree Char)
-- True
-- >>> isBST compare (Branch 5 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf))
-- False
--
isBST :: Cmp a -> Tree a -> Bool
isBST cmp = go Nothing Nothing
  where
    lt a b =
      case cmp a b of
        LT -> True
        _  -> False

    withinLower Nothing   _ = True
    withinLower (Just lo) x = lt lo x

    withinUpper Nothing   _ = True
    withinUpper (Just hi) x = lt x hi

    go _  _  Leaf = True
    go lo hi (Branch x l r) =
      withinLower lo x
        && withinUpper hi x
        && go lo (Just x) l
        && go (Just x) hi r

-- | Searches given binary search tree for
-- given value with respect to given comparison
--
-- Returns found value (might not be the one that was given)
-- wrapped into 'Just' if it was found and 'Nothing' otherwise.
--
-- Usage example:
--
-- >>> tlookup compare 2 (Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf))
-- Just 2
-- >>> tlookup compare 'a' Leaf
-- Nothing
-- >>> tlookup (\x y -> compare (x `mod` 3) (y `mod` 3)) 5 (Branch 2 (Branch 0 Leaf Leaf) (Branch 2 Leaf Leaf))
-- Just 2
--
tlookup :: Cmp a -> a -> Tree a -> Maybe a
tlookup _   _ Leaf = Nothing
tlookup cmp k (Branch x l r) =
  case cmp k x of
    EQ -> Just x
    LT -> tlookup cmp k l
    GT -> tlookup cmp k r

-- | Inserts given value into given binary search tree
-- preserving its BST properties with respect to given comparison
--
-- If the same value with respect to comparison
-- was already present in the 'Tree' then replaces it with given value.
--
-- Usage example:
--
-- >>> tinsert compare 0 (Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf))
-- Branch 2 (Branch 1 (Branch 0 Leaf Leaf) Leaf) (Branch 3 Leaf Leaf)
-- >>> tinsert compare 1 (Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf))
-- Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf)
-- >>> tinsert compare 'a' Leaf
-- Branch 'a' Leaf Leaf
--
tinsert :: Cmp a -> a -> Tree a -> Tree a
tinsert _   v Leaf = Branch v Leaf Leaf
tinsert cmp v (Branch x l r) =
  case cmp v x of
    LT -> Branch x (tinsert cmp v l) r
    GT -> Branch x l (tinsert cmp v r)
    EQ -> Branch v l r

-- | Deletes given value from given binary search tree
-- preserving its BST properties with respect to given comparison
--
-- Returns updated 'Tree' if the value was present in it;
-- or unchanged 'Tree' otherwise.
--
-- Usage example:
--
-- >>> tdelete compare 1 (Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf))
-- Branch 2 Leaf (Branch 3 Leaf Leaf)
-- >>> tdelete compare 'a' Leaf
-- Leaf
--
tdelete :: Cmp a -> a -> Tree a -> Tree a
tdelete _   _ Leaf = Leaf
tdelete cmp k (Branch x l r) =
  case cmp k x of
    LT -> Branch x (tdelete cmp k l) r
    GT -> Branch x l (tdelete cmp k r)
    EQ -> deleteRoot l r
  where
    deleteRoot :: Tree a -> Tree a -> Tree a
    deleteRoot Leaf Leaf = Leaf
    deleteRoot l'   Leaf = l'
    deleteRoot Leaf r'   = r'
    deleteRoot l'   r'   =
      let (m, r'') = extractMin r'
      in Branch m l' r''

    -- r' must be non-Leaf here
    extractMin :: Tree a -> (a, Tree a)
    extractMin Leaf = error "extractMin: unexpected Leaf"
    extractMin (Branch y Leaf ry) = (y, ry)
    extractMin (Branch y ly ry) =
      let (m, ly') = extractMin ly
      in (m, Branch y ly' ry)