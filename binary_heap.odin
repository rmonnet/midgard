// This file contains an implementation of a Binary Heap.
// The Binary Heap is a Binary Tree represented as an array where each element
// is larger than its two children.
// During insertion and deletion, the tree is re-balanced to keep the ordering property valid.
// In this implementation, the largest element is stored at the top of the tree.
//
// This implementation assumes that they values in the Priority Queue are immutables.
package midgard

import "core:testing"

// The Binary Heap structure.
// It can grow to accommodate any number of element.
Binary_Heap :: struct($T: typeid) {
	data: [dynamic]T,
	cmp:  proc(_, _: T) -> Cmp,
}

// Create a Binary Heap for the given type. The `cmp` procedure
// specifies the comparison operation used for the heap.
binary_heap_create :: proc($T: typeid, cmp: proc(_, _: T) -> Cmp) -> Binary_Heap(T) {

	res := Binary_Heap(T) {
		data = make([dynamic]T),
		cmp  = cmp,
	}
	// We always start the heap at position 1 to have an even number of elements
	append(&res.data, 0)
	return res
}

// Reclaim the memory associated with the Binary Heap.
binary_heap_destroy :: proc(b: ^Binary_Heap($T)) {

	delete(b.data)
}

// Check if the Heap is empty.
binary_heap_is_empty :: proc(b: Binary_Heap($T)) -> bool {

	return len(b.data) < 2
}

// Insert one element in the Heap.
binary_heap_insert :: proc(b: ^Binary_Heap($T), value: T) {

	append(&b.data, value)
	binary_heap_swim(b, len(b.data) - 1)

}

// Insert a slice of elements in the Heap.
binary_heap_insert_all :: proc(b: ^Binary_Heap($T), values: []T) {

	for value in values {
		binary_heap_insert(b, value)
	}
}

// Remove the greatest element from the Heap or return ok==false
// if the heap is empty.
binary_heap_remove_max :: proc(b: ^Binary_Heap($T)) -> (value: T, ok: bool) {

	if len(b.data) < 2 {return}
	max := b.data[1]
	b.data[1] = b.data[len(b.data) - 1]
	pop(&b.data)
	binary_heap_sink(b, 1)
	return max, true
}

// Returns (without removing) the greatest element from the Heap or
// return ok==false if the heap is empty.
binary_heap_max :: proc(b: ^Binary_Heap($T)) -> (value: T, ok: bool) {

	if len(b.data) < 2 {return}
	return b.data[1], true
}

// Swim re-balance the tree by moving up the element in position k
// as long as it is larger than its parent.
@(private = "file")
binary_heap_swim :: proc(b: ^Binary_Heap($T), k: int) {

	k := k
	for k > 1 && b.cmp(b.data[k / 2], b.data[k]) == .Less {
		b.data[k / 2], b.data[k] = b.data[k], b.data[k / 2]
		k = k / 2
	}
}

// Sink re-balance the tree by moving down the element in position k
// as long as its children are larger than it is.
@(private = "file")
binary_heap_sink :: proc(b: ^Binary_Heap($T), k: int) {

	k := k
	size := len(b.data) - 1
	for 2 * k <= size {
		selected_child := 2 * k
		// Pick the largest of the two children.
		if selected_child < size &&
		   b.cmp(b.data[selected_child], b.data[selected_child + 1]) == .Less {
			selected_child += 1
		}
		if b.cmp(b.data[k], b.data[selected_child]) != .Less {break}
		b.data[k], b.data[selected_child] = b.data[selected_child], b.data[k]
		k = selected_child
	}
}

// -----------------------------------------
// Tests
// -----------------------------------------

@(test)
test_binary_heap_is_empty :: proc(t: ^testing.T) {

	pq := binary_heap_create(int, cmp_int)
	defer binary_heap_destroy(&pq)

	testing.expect(t, binary_heap_is_empty(pq))
}

@(test)
test_binary_heap_is_not_empty :: proc(t: ^testing.T) {

	pq := binary_heap_create(int, cmp_int)
	defer binary_heap_destroy(&pq)
	binary_heap_insert(&pq, 1)

	testing.expect(t, !binary_heap_is_empty(pq))
}

@(test)
test_binary_heap_insert :: proc(t: ^testing.T) {

	pq := binary_heap_create(int, cmp_int)
	defer binary_heap_destroy(&pq)
	binary_heap_insert(&pq, 1)
	binary_heap_insert(&pq, 2)
	binary_heap_insert(&pq, 3)
	binary_heap_insert(&pq, 4)
	binary_heap_insert(&pq, 5)

	result, ok := binary_heap_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 5)
}

@(test)
test_binary_heap_max_when_empty :: proc(t: ^testing.T) {

	pq := binary_heap_create(int, cmp_int)
	defer binary_heap_destroy(&pq)

	_, ok := binary_heap_max(&pq)
	testing.expect(t, !ok)
}

@(test)
test_binary_heap_remove_max :: proc(t: ^testing.T) {

	pq := binary_heap_create(int, cmp_int)
	defer binary_heap_destroy(&pq)
	binary_heap_insert(&pq, 1)
	binary_heap_insert(&pq, 4)
	binary_heap_insert(&pq, 3)
	binary_heap_insert(&pq, 5)
	binary_heap_insert(&pq, 2)

	result, ok := binary_heap_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 5)

	result, ok = binary_heap_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 4)

	result, ok = binary_heap_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 3)

	result, ok = binary_heap_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 2)

	result, ok = binary_heap_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 1)

	result, ok = binary_heap_remove_max(&pq)
	testing.expect(t, !ok)
}

@(test)
test_binary_heap_insert_all :: proc(t: ^testing.T) {

	pq := binary_heap_create(int, cmp_int)
	defer binary_heap_destroy(&pq)
	binary_heap_insert_all(&pq, []int{1, 4, 3, 5, 2})

	result, ok := binary_heap_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 5)


	result, ok = binary_heap_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 4)

	result, ok = binary_heap_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 3)

	result, ok = binary_heap_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 2)

	result, ok = binary_heap_remove_max(&pq)
	testing.expect(t, ok)
	testing.expect_value(t, result, 1)

	result, ok = binary_heap_remove_max(&pq)
	testing.expect(t, !ok)
}

