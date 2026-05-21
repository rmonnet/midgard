// This file contains the implementation for the heap sort algorithm.
//
// Heap sort convert the array into a max priority queue
// using the binary heap algorithm, then sort the array
// by transferring the elements, starting with the largest,
// to the end of the array.
//
// The sort is not stable.
// Its worst case performance is O(N Log N).
// The algorithm sorts in-place (no extra space required)
// In practice there are more operations to do than Quick Sort and
// Heap Sort doesn't play nice with the CPU cache.
package midgard

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
heap_sort :: proc(xs: []$T, cmp: proc(a, b: T) -> Cmp) {

	// For the node at index k, push it down until all the nodes above
	// in its parent branch are larger.
	// Note: The Binary_Heap implementation has the first heap element
	// at index 1. This implementation starts at index 0.
	sink :: proc(xs: []T, k: int, size: int, cmp: proc(a, b: T) -> Cmp) {

		k := k
		for 2 * k < (size - 1) {
			selected_child := 2 * k + 1
			// Pick the largest of the two children.
			if selected_child < (size - 1) &&
			   cmp(xs[selected_child], xs[selected_child + 1]) == .Less {
				selected_child += 1
			}
			if cmp(xs[k], xs[selected_child]) != .Less {break}
			xs[k], xs[selected_child] = xs[selected_child], xs[k]
			k = selected_child
		}
	}

	size := len(xs)
	// First convert the array into a max priority queue
	// by using the binary heap algorithm.
	for k := (size / 2) - 1; k >= 0; k -= 1 {
		sink(xs, k, size, cmp)
	}
	// Then, iteratively, copy the largest remaining element to
	// the back of the array.
	for size > 1 {
		xs[0], xs[size - 1] = xs[size - 1], xs[0]
		size -= 1
		sink(xs, 0, size, cmp)
	}
}

