[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/X1O8xjNW)
# Haskell: Trees

<img alt="points bar" align="right" height="36" src="../../blob/badges/.github/badges/points-bar.svg" />

<details>
<summary>Guidelines</summary>

## Guidelines

When solving the homework, strive to create not just code that works, but code that is readable and concise.
Try to write small functions which perform just a single task, and then combine those smaller
pieces to create more complex functions.

Don’t repeat yourself: write one function for each logical task, and reuse functions as necessary.

Don't be afraid to introduce new functions where you see fit.

### Sources

Each task has corresponding source file in [src](src) directory where you should implement the solution.

### Building

All solutions should compile without warnings with following command:

```bash
stack build
```

### Testing

You can and should run automated tests before pushing solution to GitHub via

```bash
stack test --test-arguments "-p TaskX"
```

where `X` in `TaskX` should be number of corresponding Task to be tested.

So to run all test for the first task you should use following command:

```bash
stack test --test-arguments "-p Task1"
```

You can also run tests for all tasks with just

```bash
stack test
```

### Debugging

For debugging you should use GHCi via stack:

```bash
stack ghci
```

You can then load your solution for particular task using `:load TaskX` command.

Here is how to load Task1 in GHCi:

```bash
$ stack ghci
ghci> :load Task1
[1 of 1] Compiling Task1 ( .../src/Task1.hs, interpreted )
Ok, one module loaded.
```

> **Note:** if you updated solution, it can be quickly reloaded in the same GHCi session with `:reload` command
> ```bash
> ghci> :reload
> ```

</details>

## Preface

In this assignment you will implement some basic tree processing functionality
starting with traversal, binary search tree and then implementing tree-based map structure.
Each task is based on results from all previous ones, so they should be implemented in order.

## Task 1 (3 points)

### Tree traversal

The first task is to define functions for traversing tree and forest (list of trees).

There are [many ways](https://en.wikipedia.org/wiki/Tree_traversal) to traverse trees.
However, we will focus on the most common ones derived from depth-first search:

- Pre-order
- In-order
- Post-order

All of which are perfectly summarized in [Wikipedia](https://en.wikipedia.org/wiki/Tree_traversal#Depth-first_search):

[![](https://upload.wikimedia.org/wikipedia/commons/7/75/Sorted_binary_tree_ALL_RGB.svg)](https://en.wikipedia.org/wiki/Tree_traversal#Depth-first_search)

> Depth-first traversal (dotted path) of a binary tree:  
> Pre-order (node visited at position red ●):  
>     F, B, A, D, C, E, G, I, H;  
> In-order (node visited at position green ●):  
>     A, B, C, D, E, F, G, H, I;  
> Post-order (node visited at position blue ●):  
>     A, C, E, D, B, H, I, G, F.

### Task

In [src/Task1.hs](src/Task1.hs) you will find following type definitions of
binary tree, forest and enumeration of selected orders:

```haskell
data Tree a = Leaf a | Branch a (Tree a) (Tree a)
  deriving Show

type Forest a = [Tree a]

data Order = PreOrder | InOrder | PostOrder
  deriving Show
```

> Feel free to derive other constraints like `Eq` if necessary. 

Your goal is to implement following functions for tree and forest traversal:

- `torder` which returns values of given `Tree` in specified `Order` with optional leaf value
  ```haskell
  torder :: Order    -- ^ Order of resulting traversal
         -> Maybe a  -- ^ Optional leaf value
         -> Tree a   -- ^ Tree to traverse
         -> [a]      -- ^ List of values in specified order
  ```
  **Example:**
  ```haskell
  >>> torder PreOrder  (Just '.') (Branch 'A' Leaf (Branch 'B' Leaf Leaf))
  "A.B.."
  >>> torder InOrder   (Just '.') (Branch 'A' Leaf (Branch 'B' Leaf Leaf))
  ".A.B."
  >>> torder PostOrder (Just '.') (Branch 'A' Leaf (Branch 'B' Leaf Leaf))
  "...BA"
  ```
- `forder` which returns values of given `Forest` separated by optional separator (first `Maybe` arg)
  where each tree is traversed in specified `Order` with optional leaf value (second `Maybe` arg)
  ```haskell
  forder :: Order     -- ^ Order of tree traversal
         -> Maybe a   -- ^ Optional separator between resulting tree orders
         -> Maybe a   -- ^ Optional leaf value
         -> Forest a  -- ^ List of trees to traverse
         -> [a]       -- ^ List of values in specified tree order
  ```
  **Example:**
  ```haskell
  >>> forder PreOrder  (Just '|') (Just '.') [Leaf, Branch 'C' Leaf Leaf, Branch 'A' Leaf (Branch 'B' Leaf Leaf)]
  ".|C..|A.B.."
  >>> forder InOrder   (Just '|') (Just '.') [Leaf, Branch 'C' Leaf Leaf, Branch 'A' Leaf (Branch 'B' Leaf Leaf)]
  ".|.C.|.A.B."
  >>> forder PostOrder (Just '|') (Just '.') [Leaf, Branch 'C' Leaf Leaf, Branch 'A' Leaf (Branch 'B' Leaf Leaf)]
  ".|..C|...BA"
  ```

> [!TIP]
>
> For this task you might want to implement and use functions
> [maybeToList](https://hackage.haskell.org/package/base-4.21.0.0/docs/Data-Maybe.html#v:maybeToList) and
> [intercalate](https://hackage.haskell.org/package/base-4.21.0.0/docs/Data-List.html#v:intercalate).
>
> Feel free to check out their documentation, but please try to implement them yourself without looking into library source code.

## Task 2 (4 points)

### Binary search tree

The second task is to implement common [binary search tree](https://en.wikipedia.org/wiki/Binary_search_tree)
(BST) API: searching, insertion and deletion.

![](https://upload.wikimedia.org/wikipedia/commons/d/da/Binary_search_tree.svg)

### Comparison

To implement BST you will need some way to compare elements.
One way would be to add constraint `Ord a =>` to all the functions,
which is a usual approach to do such things.

However, for this task you will explicitly pass *comparison function* to all required functions instead.
The comparison function will return element of the enumeration `Ordering` indicating whether its
first argument is less, equal or greater than the second one:

```haskell
data Ordering = LT | EQ | GT
  deriving Show
```

> Feel free to derive other constraints like `Eq` if necessary. 

We have also introduced a helper type synonym for such comparison function's signature:

```haskell
type Cmp a = a -> a -> Ordering
```

To have some compatibility with built-in comparison facilities of `Ord`, you should define following
function which induces comparison from `Ord` constraint:

```haskell
compare :: Ord a => Cmp a
```

This function allows us to compare all built-in comparable types:

```haskell
>>> compare 2 3
LT
>>> compare 'a' 'a'
EQ
>>> compare "Haskell" "C++"
GT
```

> [!NOTE]
>
> [Ordering](https://hackage.haskell.org/package/base-4.21.0.0/docs/Data-Ord.html#t:Ordering) and
> [compare](https://hackage.haskell.org/package/base-4.21.0.0/docs/Data-Ord.html#v:compare) are actually
> provided by `Prelude`.
>
> But in the spirit of learning they are explicitly defined in [src/Task2.hs](src/Task2.hs) for you to implement.

### List conversion

Next you need to define following functions for conversion of BST to and from lists:

- `listToBST` which constructs binary search tree from list using given comparison function
  ```haskell
  listToBST :: Cmp a -> [a] -> Tree a
  ```
  **Example:**
  ```haskell
  >>> listToBST compare [2,3,1]
  Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf)
  >>> listToBST compare ""
  Leaf
  ```
  > Note: the exact structure of produced BST does not need to match the examples
  > as long as the result is actually a valid *binary search tree*.

- `bstToList` which converts binary search tree back to a list
  ```haskell
  bstToList :: Tree a -> [a]
  ```
  **Example:**
  ```haskell
  >>> bstToList (Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf))
  [1,2,3]
  >>> bstToList Leaf
  []
  ```
  
  The resulting list will be sorted according to the comparison function
  with which original BST was constructed (if it was really a BST of course).
  
<details>
<summary>Hint</summary>

> Use one of the traversal orders defined in first task to turn BST into a list.

</details>

In order to verify that produced trees that you are getting are really *binary search trees*
define a validation function `isBST` that will tell whether given tree satisfies formal criteria
for BST using given comparison:

```haskell
isBST :: Cmp a -> Tree a -> Bool
```

> [!NOTE]
>
> Notice that by providing comparison function explicitly, we can change whether
> the same tree considered binary search tree or not.
  
### Search

For efficient searching of an element in BST you should implement the following function:

```haskell
tlookup :: Cmp a -> a -> Tree a -> Maybe a
```
**Example:**
```haskell
>>> tlookup compare 2 (Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf)) Just 2
Just 2
>>> tlookup compare 'a' Leaf
Nothing
>>> tlookup (\x y -> compare (x `mod` 3) (y `mod` 3)) 5 (Branch 2 (Branch 0 Leaf Leaf) (Branch 2 Leaf Leaf))
Just 2
```

This function accepts comparison function, value to search and BST,
and instead of returning simple boolean result it returns `Maybe` wrapper,
with found element wrapped into `Just` if it is found or `Nothing` otherwise.

> [!IMPORTANT]
>
> Due to our choice to explicitly pass comparison function, the searched value might not
> be equal to the found element in terms of regular equality with `(==)`.
> So this lookup function must return *found* element and not the searched value.
  
### Insertion

For efficient insertion of an element into BST you should implement the following function:

```haskell
tinsert :: Cmp a -> a -> Tree a -> Tree a
```
**Example:**
```haskell
>>> tinsert compare 0 (Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf))
Branch 2 (Branch 1 (Branch 0 Leaf Leaf) Leaf) (Branch 3 Leaf Leaf)
>>> tinsert compare 1 (Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf))
Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf)
>>> tinsert compare 'a' Leaf
Branch 'a' Leaf Leaf
```

This function accepts comparison function, value to insert, BST and returns new BST
with given value inserted into proper place if tree did not contain it,
or *updating* the existing element with the new value.

> [!IMPORTANT]
>
> Due to our choice to explicitly pass comparison function, the inserted value might not
> be equal to the existing element in terms of regular equality with `(==)`.
> So this insertion function must update the tree with new value even if it found existing element
> which is "the same" in terms of given comparison function.
  
### Deletion

For efficient deletion of an element from BST you should implement the following function:

```haskell
tdelete :: Cmp a -> a -> Tree a -> Tree a
```
**Example:**
```haskell
>>> tdelete compare 1 (Branch 2 (Branch 1 Leaf Leaf) (Branch 3 Leaf Leaf))
Branch 2 Leaf (Branch 3 Leaf Leaf)
>>> tdelete compare 'a' Leaf
Leaf
```

This function accepts comparison function, value to delete, BST and returns new BST
with given value deleted if it was contained in BST with respect to given comparison.

## Task 3 (3 points)

### Tree-based map

The third and last task is to implement a key-value map structure on top of *binary search tree*
that you implemented in previous task.
It should provide the same API as BST: search, insertion and deletion.

However, this time lets use `Ord` constraint in API instead of passing explicit comparison function.

> **Reminder**
>
> Please avoid code duplication and import any previously defined functions from `Task1` and `Task2`
> if you need them.

> [!NOTE]
>
> This tree-based implementation is similar to the most commonly used map implementation
> of [Data.Map](https://hackage.haskell.org/package/containers-0.4.0.0/docs/Data-Map.html)
> from standard [containers](https://hackage.haskell.org/package/containers-0.4.0.0) package.
>
> The library implementation of map of course uses a *size-balanced tree* to bring
> the worst-case complexity from `O(n)` of our regular binary search tree to `O(log n)`.
>
> You might think that `O(log n)` is unacceptable complexity when compared to amortized `O(1)`
> of hash map. But tree-based map implementations actually have some advantages over
> hash map in functional language context:
>
> - Most tree-based implementations provide automatic sorting, provided there is an `Ord` constraint on keys
>   (which they usually have out of the box)
> - Tree-based maps *do not* require key to be hashable (which it often might not be)
> - Trees are recursive data structures, allowing creation of infinite trees and key-value maps
>   which can be initialized lazily (just like infinite lists which are also recursive)
> - Trees are inherently *immutable* and *persistent* which allows them to be efficiently used
>   and reused in pure functions (it is also possible to implement immutable and persistent
>   hash map, for example with [hash array mapped trie](https://en.wikipedia.org/wiki/Hash_array_mapped_trie),
>   but the implementation becomes much more involved and complicated)
>
> Of course some applications really require faster element lookup and for such cases
> (provided keys are hashable and their ordering is not required) there is established
> package [unordered-containers](https://hackage.haskell.org/package/unordered-containers-0.2.20)
> which provides *immutable* hash-based map and set implementation.

### Type

In [src/Task3.hs](src/Task3.hs) you will find following type synonym for key-value map
based on `Tree` type introduced in the first task:

```haskell
type Map k v = Tree (k, v)
```

### Comparison

The comparison for the BST element `(k, v)` should be induced from `Ord k` constraint on keys
in API.

However, once you start implementing functions below, you will see that it is not as simple
as it sounds. The underlying BST operations will need comparison `Cmp (k, v)`, but we only have `Ord`
constraint on the keys. So pairs `(k, v)` will not be instance of `Ord` out-of-the-box.

So when supporting functions below, try to come up with a solution to this problem
that *does not* require `Ord v` for values.

If you find yourself stuck, return to this section and check out hints below.

<details>
<summary>Hint</summary>

Try to write your own comparison function on pairs that uses only `Ord k` for keys
and ignores the values completely:

```haskell
compareKeys :: Ord k => Cmp (k, v)
```

Once you have it, most of the functions will be easy to implement,
except the ones where you don't have actual key-value pair to compare with,
but only have the key.

It might seem impossible to obtain a key-value pair without having additional
constraints on value type (e.g. have it be `Bounded v` and use `minBound` as placeholder for value).

But it is actually possible, especially in Haskell.

Try to figure out the solution on your own, and if you are really stuck, check out the next hint.

<details>
<summary>Another hint</summary>

Remember that Haskell is lazy language! Find a way to abuse it for this particular problem.

<details>
<summary>Final hint</summary>

We might have no information about the type `v` or if it even has any values to use
as placeholder for pair comparison.
But there are built-in polymorphic functions that you can use in place of any other type,
which will definitely help in this case.

</details>

</details>

</details>

### List conversion

Again you will need a way to convert map to and from association list of pairs
using defined previously conversions for BST:

- `listToMap` which constructs key-value map from given association list
  ```haskell
  listToMap :: Ord k -> [(k,v)] -> Map k v
  ```
  **Example:**
  ```haskell
  >>> listToMap [(2,'a'),(3,'c'),(1,'b')]
  Branch (2,'a') (Branch (1,'b') Leaf Leaf) (Branch (3,'c') Leaf Leaf)
  >>> listToMap [] :: Map Int Char
  Leaf
  ```
- `mapToList` which converts given map back to association list
  ```haskell
  bstToList :: Map k v -> [(k, v)]
  ```
  **Example:**
  ```haskell
  >>> mapToList (Branch (2,'a') (Branch (1,'b') Leaf Leaf) (Branch (3,'c') Leaf Leaf))
  [(1,'b'),(2,'a'),(3,'c')]
  >>> mapToList Leaf
  []
  ```
  The resulting list will be sorted by keys.
  
### Search

To find a value associated with a key you should implement the following function
using previously defined `tlookup`:

```haskell
mlookup :: Ord k => k -> Map k v -> Maybe v
```
**Example:**
```haskell
>>> mlookup 1 (Branch (2,'a') (Branch (1,'b') Leaf Leaf) (Branch (3,'c') Leaf Leaf))
Just 'b'
>>> mlookup 'a' Leaf
Nothing
```

This function searches map for given key and returns associated value
wrapped into `Just` if it is found or returns `Nothing` otherwise.
  
### Insertion

To associate key with a value in map you should implement the following function
using previously defined `tinsert`:

```haskell
minsert :: Ord k => k -> v -> Map k v -> Map k v
```
**Example:**
```haskell
>>> minsert 0 'd' (Branch (2,'a') (Branch (1,'b') Leaf Leaf) (Branch (3,'c') Leaf Leaf))
Branch (2,'a') (Branch (1,'b') (Branch (0,'d') Leaf Leaf) Leaf) (Branch (3,'c') Leaf Leaf)
>>> minsert 1 'X' (Branch (2,'a') (Branch (1,'b') Leaf Leaf) (Branch (3,'c') Leaf Leaf))
Branch (2,'a') (Branch (1,'X') Leaf Leaf) (Branch (3,'c') Leaf Leaf)
>>> minsert 1 'X' Leaf
Branch (1,'X') Leaf Leaf
```

If given key was already present in the map the associated value should
be updated with the new one.
  
### Deletion

To delete a key and its associated value from map you should implement the following function
using previously defined `tdelete`:

```haskell
mdelete :: Ord k => k -> Map k v -> Map k v
```
**Example:**
```haskell
>>> mdelete 1 (Branch (2,'a') (Branch (1,'b') Leaf Leaf) (Branch (3,'c') Leaf Leaf))
Branch (2,'a') Leaf (Branch (3,'c') Leaf Leaf)
>>> mdelete 'a' Leaf
Leaf
```
