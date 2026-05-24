/*
This file contains an implementation of a Max Binary Heap.

References:
- Algorithms by Sedgewick and Wayne, Lecture 7

The Binary Heap is a Binary Tree such that all levels are populated except some of the last level.
The heap is such that each element is larger than its two children (ordering property).

During insertion and deletion, the tree is re-balanced to keep the ordering property valid.
In this implementation, the largest element is stored at the top of the tree (Max Binary Heap).

We use an array to represent the binary tree.
If an element is at index `k`, its left child is at `2k` and its right child is at `2k+1`.

This implementation assumes that they values in the Priority Queue are immutables and not dynamically allocated.

We are assuming that the element type is Totally Ordered and that we only need to define
the `less_than` procedure to specify all the comparison operators for the set.
*/
package dsa

// `Binary_Heap` defines the Binary Heap structure.
// It can grow to accommodate any number of element.
Binary_Heap :: struct($T: typeid) {
	data:      [dynamic]T,
	less_than: proc(_, _: T) -> bool,
}

// `bh_create` creates a Binary Heap for the given type.
// The `less` procedure specifies the comparison operation used for the heap.
bh_create :: proc($T: typeid, less_than: proc(_, _: T) -> bool) -> Binary_Heap(T) {

	res := Binary_Heap(T) {
		data      = make([dynamic]T),
		less_than = less_than,
	}
	// We always start the heap at position 1 to have an even number of elements
	append(&res.data, 0)
	return res
}

// `bh_destroy` reclaims the memory associated with the Binary Heap.
bh_destroy :: proc(b: ^Binary_Heap($T)) {

	delete(b.data)
}

// `bh_size` returns the number of elements in the heap.
bh_size :: proc(b: Binary_Heap($T)) -> int {

	// The count is off by one because of the dummy element at position 0.
	return len(b.data) - 1
}

// `bh_insert` adds one element to the Heap.
bh_insert :: proc(b: ^Binary_Heap($T), element: T) {

	append(&b.data, element)
	bh_swim(b, len(b.data) - 1)

}

// `bh_insert_all` adds a slice of elements in the Heap.
bh_insert_all :: proc(b: ^Binary_Heap($T), elements: []T) {

	for element in elements {
		bh_insert(b, element)
	}
}

// `bh_remove_max` removes the greatest element from the Heap and returns it.
// The success return value indicates if an element was returned.
bh_remove_max :: proc(b: ^Binary_Heap($T)) -> (element: T, success: bool) {

	// The 1st element is the max, we swap it with the last element in the tree
	// and call `bh_sink` to restore the binary heap property.
	if len(b.data) < 2 {return}
	max := b.data[1]
	b.data[1] = b.data[len(b.data) - 1]
	pop(&b.data)
	bh_sink(b, 1)
	return max, true
}

// `bh_max` returns (without removing) the greatest element from the tree.
// The success return value indicates if an element was returned.
bh_max :: proc(b: ^Binary_Heap($T)) -> (element: T, success: bool) {

	if len(b.data) < 2 {return}
	return b.data[1], true
}

// `bh_swim` re-balances the tree by moving up the element in position k
// as long as it is larger than its parent.
@(private = "file")
bh_swim :: proc(b: ^Binary_Heap($T), k: int) {

	k := k
	for k > 1 && b.less_than(b.data[k / 2], b.data[k]) {
		b.data[k / 2], b.data[k] = b.data[k], b.data[k / 2]
		k = k / 2
	}
}

// `bh_sink` re-balances the tree by moving down the element in position k
// as long as its children are larger than it is.
@(private = "file")
bh_sink :: proc(b: ^Binary_Heap($T), k: int) {

	k := k
	size := len(b.data) - 1
	for 2 * k <= size {
		selected_child := 2 * k
		// Pick the largest of the two children.
		if selected_child < size &&
		   b.less_than(b.data[selected_child], b.data[selected_child + 1]) {
			selected_child += 1
		}
		if !b.less_than(b.data[k], b.data[selected_child]) {break}
		b.data[k], b.data[selected_child] = b.data[selected_child], b.data[k]
		k = selected_child
	}
}

// -----------------------------------------
// Tests
// -----------------------------------------

import "core:testing"

@(test)
test_bh_is_empty :: proc(t: ^testing.T) {

	pq := bh_create(int, proc(a, b: int) -> bool {return a < b})
	defer bh_destroy(&pq)

	testing.expect_value(t, bh_size(pq), 0)
}

@(test)
test_bh_is_not_empty :: proc(t: ^testing.T) {

	pq := bh_create(int, proc(a, b: int) -> bool {return a < b})
	defer bh_destroy(&pq)
	bh_insert(&pq, 1)

	testing.expect_value(t, bh_size(pq), 1)
}

@(test)
test_bh_insert :: proc(t: ^testing.T) {

	pq := bh_create(int, proc(a, b: int) -> bool {return a < b})
	defer bh_destroy(&pq)
	bh_insert(&pq, 1)
	bh_insert(&pq, 4)
	bh_insert(&pq, 3)
	bh_insert(&pq, 5)
	bh_insert(&pq, 2)

	result, ok := bh_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 5)
}

@(test)
test_bh_max_when_empty :: proc(t: ^testing.T) {

	pq := bh_create(int, proc(a, b: int) -> bool {return a < b})
	defer bh_destroy(&pq)

	_, ok := bh_max(&pq)
	testing.expect(t, !ok)
}

@(test)
test_bh_remove_max :: proc(t: ^testing.T) {

	pq := bh_create(int, proc(a, b: int) -> bool {return a < b})
	defer bh_destroy(&pq)
	bh_insert(&pq, 1)
	bh_insert(&pq, 4)
	bh_insert(&pq, 3)
	bh_insert(&pq, 5)
	bh_insert(&pq, 2)

	result, ok := bh_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 5)

	result, ok = bh_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 4)

	result, ok = bh_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 3)

	result, ok = bh_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 2)

	result, ok = bh_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 1)

	result, ok = bh_remove_max(&pq)
	testing.expect(t, !ok)
}

@(test)
test_bh_insert_all :: proc(t: ^testing.T) {

	pq := bh_create(int, proc(a, b: int) -> bool {return a < b})
	defer bh_destroy(&pq)
	bh_insert_all(&pq, []int{1, 4, 3, 5, 2})

	result, ok := bh_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 5)


	result, ok = bh_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 4)

	result, ok = bh_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 3)

	result, ok = bh_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 2)

	result, ok = bh_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 1)

	result, ok = bh_remove_max(&pq)
	testing.expect(t, !ok)
}

