# Midgard, an Odin Library

Midgard is a collection of algorithms and data structure that I built to refresh my knowledge and explore interesting algorithms.

Midgard is not meant to be used as a library but more like a museum or a zoo (depending on your perspective on Computer Science).
Each piece is presented as a standalone work, and can be lifted to be used in your work as a starting block.
The file contains the source code, some documentation, and a set of tests.

I chose Odin as the implementation language because it is simple, very readable, and doesn't hide the details of the memory management behind a garbage collector.
The code should be easy to port to your favorite language if you need to.

Note: The Odin standard library already includes some of the algorithms and data structures listed here.
They are not used on purpose since the goal is to learn and demonstrate. 

This library is built without AI coding agents because the goal of the exercise is to learn and I learn best by doing.
I do, however, use Claude and Gemini in a separate window as mentors when I have specific questions and need to do research.

The code in this collection is released under the MIT open source license but use at your own peril.

## Pre-requisite

You need to install the [Odin compiler](https://odin-lang.org/).

If you are using [VSCode](https://code.visualstudio.com/), I recommend the Odin Language extension by Daniel Gavin ('danielgavin.ols').
I have switched to [Zed](https://zed.dev/) with the Odin extension because I found it better for visualizing program states when debugging.

For running tasks, this project uses [just](https://just.systems/man/en/introduction.html). It is similar to make but simpler.
You can install it using (`brew install just` on macOS, `scoop install just` on Windows11, or your Linux distro package manager).
You can also install with `cargo install just` if you have the Rust toolchain installed and don't mind the extra space taken by the downloaded dependencies.

To count lines of code, this project uses [tokei](https://github.com/XAMPPRocky/tokei).
You can install it using (`brew install tokei` on macOS, `scoop install tpkei` on Windows11, or your Linux distro package manager).
You can also install with `cargo install tokei` if you have the Rust toolchain installed and don't mind the extra space taken by the downloaded dependencies.


## Algorithms and Data Structures

Here is a quick summary of the collection of algorithms and data structures.
When multiple versions of the same data structure or algorithm is included, the convention is for the type name to show the specialization first (ex: `Array_Stack`) while the file name shows the generic name first (ex: `stack_array.odin`). This groups all the related source code together while still providing type and procedure names that roll off the tongue..

### Algorithms

- Selection: Algorithms to select an element from an ordered collection.
  - [quick_select](./sort_quick.odin): Select the k-th element of an array without sorting it. The k-th element represents the element that would be in k position after sorting the array (k=0 => min, k=len-1 => max, k=len/2 => median) 
- Sort: A set of algorithms sorting slices. Odin slices represents arrays of any size. Each sort algorithm has two versions: the first assumes a numeric array supporting the `<` operator, the second uses a argument procedure (`proc(a, b:T -> bool)`) to compare elements.
  - [bottom_merge_sort](./sort_bottom_merge.odin):  Sorts by iteratively sorting sub-arrays of the input array, using the merge sort merge algorithm and gradually building up to the two half of the array. 
  - [heap_sort](./sort_hep.odin): Sort the array using the Binary Heap algorithm. It convert the array into a max binary heap and then copying the heap elements, largest to the end of the array and iteratively with the remaining largest.
  - [insertion_sort](./sort_insertion.odin): Sorts by iteratively inserting each element of an unsorted list into its correct position in a sorted portion of the list.
  - [selection_sort](./sort_selection.odin): Sorts by repeatedly selecting the smallest element from the unsorted portion and swapping it with the first unsorted element.
  - [shell_sort](./sort_shell.odin): Sorts by sorting pairs of elements that are far apart from each other and progressively reducing the gap between elements to be compared. It is an optimization of insertion sort.
  - [merge_sort](./sort_merge.odin):  Sorts by recursively dividing the input array into two halves, recursively sorting the two halves and finally merging them back together to obtain the sorted array.
  - [quick_sort](./sort_quick.odin): Sorts by recursively partitioning the array into the sub-array of values smaller than a selected value and the sub-array of values larger than a selected value until all the values are sorted.
  - [three_way_quick_sort](./sort_quick.odin): This a variant of `quick_sort` optimized for cases where the array contains several duplicate keys.
- Shuffle: Algorithm to randomly shuffle a set of elements.
  - [shuffle](./shuffle.odin): Shuffle the elements of an array with the result being uniformly distributed.

### Data Structures

- Union-Find: A set data structure that determines if there is a path between two nodes.
  - [Compressed_Union_Find](./union_find_compressed.odin): Faster version using an array of nodes where each node points towards the root of the connected set. When connecting two nodes, the root is selected as the root of the largest of the two sets to keep the depth of the tree shallow and speed up root lookup. When looking up a root, the tree is compressed by swapping each node root with its grand-parent root. Over time, this speeds up root lookup by decreasing the depth of the tree.
  - [Quick_Union_Find](./union_find_quick.odin): Faster version using an array of nodes where each node points towards the root of the connected set.
  -  [Union_Find](./union_find.odin): Naive version using an array of nodes where each node points towards one element of the connected set.
  - [Weighted_Union_Find](./union_find_weigthed.odin): Faster version using an array of nodes where each node points towards the root of the connected set. When connecting two nodes, the root is selected as the root of the largest of the two sets to keep the depth of the tree shallow and speed up root lookup.
- Map: A Map allows the storage and retrieval of the value associated with a specific key.
  - [Map](./map.odin): A simple implementation of a Map using a linked list of (key, value) pairs.
  - [Ordered_Map](./map_ordered.odin): An implementation of a Map using a sorted array of (key, value) pairs and binary search to find a key in the array.
- Priority Queue: A Queue where the elements are retrieved in priority order, the element with the maximum (or minimum) value first.
  - [Binary_Heap](.binary_heap.odin): A Priority Queue based on a binary tree, itself implemented using an array.
- Queue: The classic First In - First Out container.
  - [Array_Queue](./queue_array.odin): Queue implemented as a growable array.
  - [Queue](./queue.odin): Queue implemented as a linked list.
- Stack: The classic Last In - First Out container.
  - [Array_Stack](./stack_array): Stack implemented as a growable array.
  - [Stack](./stack.odin): Stack implemented as a linked list.

## To Do

- [ ] Implement the Convex Hull Algorithm (Sedgewick Algorithms, Lecture 4)
- [ ] Implement the Bouncing Ball simulation using a Priority Queue (Sedgewick Algorithms, Lecture 7)

## License and Copyright

The code is copyrighted Robert Monnet 2026 and is provided under the [MIT License](https://opensource.org/license/mit).
