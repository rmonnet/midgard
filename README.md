# Midgard, an Odin Library

Midgard is a collection of algorithms and data structure that I built to refresh my knowledge.

I chose Odin as the implementation language because it is very readable and doesn't hide the details of the memory management behind a garbage collector.

This library is built without AI coding agents because the goal of the exercise is to learn and I learn by doing.
I do, however, use Claude and Gemini in a separate window as tutors when I have specific questions and need to do research.

The code in this collection is released under the MIT open source license but use at your own peril.

## Pre-requisite

You need to install the [Odin compiler](https://odin-lang.org/).

If you are using [VSCode](https://code.visualstudio.com/), I recommend the Odin Language extension by Daniel Gavin ('danielgavin.ols').
I have switched to [Zed](https://zed.dev/) with the Odin extension because I found easier to visualize program states when debugging.

## Algorithms and Data Structures

Here is a quick summary of the collection of algorithms and data structures.
When multiple version of the same data structure or algorithm is included, the convention is for the type name to show the specialization first (ex: `Array_Stack`) while the file name shows the generic name first (ex: `stack_array.odin`). This makes it easy to spot the different implementations in the source code while still having names that feel more natural.

### Algorithms

- Sort: A set of algorithms sorting slices. Odin slices represents arrays of any size. Each sort algorithm has two versions: the first assumes a numeric array supporting the `<` operator, the second uses a argument procedure (`proc(a, b:T -> bool)`) to compare elements.
  - [selection_sort](./sort.odin): Sorts by repeatedly selecting the smallest element from the unsorted portion and swapping it with the first unsorted element.
  - [insertion_sort](./sort.odin): Sorts by iteratively inserting each element of an unsorted list into its correct position in a sorted portion of the list.
  - [shell_sort](./sort.odin): Sorts by sorting pairs of elements that are far apart from each other and progressively reducing the gap between elements to be compared. It is an optimization of insertion sort.
  - [merge_sort](./sort.odin):  Sorts by recursively dividing the input array into two halves, recursively sorting the two halves and finally merging them back together to obtain the sorted array. 

### Data Structures

- Union-Find: A set data structure that determines if there is a path between two nodes.
  -  [Union_Find](./union_find.odin): Naive version using an array of nodes where each node points towards one element of the connected set.
  - [Quick_Union_Find](./union_find_quick.odin): Faster version using an array of nodes where each node points towards the root of the connected set.
  - [Weighted_Union_Find](./union_find_weigthed.odin): Faster version using an array of nodes where each node points towards the root of the connected set. When connecting two nodes, the root is selected as the root of the largest of the two sets to keep the depth of the tree shallow and speed up root lookup.
  - [Compressed_Union_Find](./union_find_compressed.odin): Faster version using an array of nodes where each node points towards the root of the connected set. When connecting two nodes, the root is selected as the root of the largest of the two sets to keep the depth of the tree shallow and speed up root lookup. When looking up a root, the tree is compressed by swapping each node root with its grand-parent root. Over time, this speeds up root lookup by decreasing the depth of the tree.
 - Stack: The classic Last In - First Out container.
  - [Stack](./stack.odin): Stack implemented as a linked list.
  - [Array_Stack](./stack_array): Stack implemented as a growable array.
- Queue: The classic First In - First Out container.
  - [Queue](./queue.odin): Queue implemented as a linked list.
  - [Array_Queue](./queue_array.odin): Queue implemented as a growable array.

## License and Copyright

The code is copyrighted Robert Monnet 2026 and is provided under the [MIT License](https://opensource.org/license/mit).
