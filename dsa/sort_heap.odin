// This file contains the implementation for the Heap Sort algorithm.
//
// Heap Sort converts the array into a max priority queue
// using the binary heap algorithm, then sort the array
// by transferring the elements, starting with the largest,
// to the end of the array.
//
// We are assuming that the element type is Totally Ordered and that
// we only need to define the `less_than` procedure to specify all the
// comparison operators for the set.
//
// The sort is not stable.
// Its worst case performance is O(N Log N).
// The algorithm sorts in-place (no extra space required)
// In practice there are more operations to do than Quick Sort and
// Heap Sort doesn't play nice with the CPU cache.
package dsa

// Sort the xs slice in place, using the `less_than` procedure
//  parameter to compare elements.
heap_sort :: proc(xs: []$T, less_than: proc(a, b: T) -> bool) {

	// For the node at index k, push it down until all the nodes above
	// in its parent branch are larger.
	// Note: The Binary_Heap implementation has the first heap element
	// at index 1. This implementation starts at index 0.
	sink :: proc(xs: []T, k: int, size: int, less_than: proc(a, b: T) -> bool) {

		k := k
		for 2 * k < (size - 1) {
			selected_child := 2 * k + 1
			// Pick the largest of the two children.
			if selected_child < (size - 1) &&
			   less_than(xs[selected_child], xs[selected_child + 1]) {
				selected_child += 1
			}
			if !less_than(xs[k], xs[selected_child]) {break}
			xs[k], xs[selected_child] = xs[selected_child], xs[k]
			k = selected_child
		}
	}

	size := len(xs)
	// First convert the array into a max priority queue
	// by using the binary heap algorithm.
	for k := (size / 2) - 1; k >= 0; k -= 1 {
		sink(xs, k, size, less_than)
	}
	// Then, iteratively, copy the largest remaining element to
	// the back of the array.
	for size > 1 {
		xs[0], xs[size - 1] = xs[size - 1], xs[0]
		size -= 1
		sink(xs, 0, size, less_than)
	}
}

// ------------------------------------------
// Tests
// ------------------------------------------

import "core:math/rand"
import "core:slice"
import "core:strings"
import "core:testing"

@(test)
hs_test_sort_int :: proc(t: ^testing.T) {

	xs := []int{17, 5, 20, 1, 12, 10, 18, 3, 9, 16, 2, 13, 14, 8, 7, 6, 4, 12, 2, 19, 15, 11}
	expected := []int{1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20}
	heap_sort(xs, proc(a, b: int) -> bool {return a < b})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

@(test)
hs_test_sort_float :: proc(t: ^testing.T) {

	xs: [1000]f64
	for i in 0 ..< len(xs) {xs[i] = rand.float64()}
	heap_sort(xs[:], proc(a, b: f64) -> bool {return a < b})

	// Checking that the array is sorted
	for i in 1 ..< len(xs) {
		if xs[i - 1] >= xs[i] {
			testing.expectf(
				t,
				false,
				"Sort fails: xs[%d](%f) >= xs[%d](%f)\n",
				i - 1,
				xs[i - 1],
				i,
				xs[i],
			)
		}
	}
}

@(test)
hs_test_sort_string :: proc(t: ^testing.T) {

	xs := strings.split("qetaljrcipbmnhgfdlbsok", "")
	defer delete(xs)
	expected := strings.split("abbcdefghijkllmnopqrst", "")
	defer delete(expected)

	heap_sort(xs, proc(a, b: string) -> bool {return a < b})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

@(test)
hs_test_sort_string_reverse :: proc(t: ^testing.T) {

	xs := strings.split("qetaljrcipbmnhgfdlbsok", "")
	defer delete(xs)
	expected := strings.split("tsrqponmllkjihgfedcbba", "")
	defer delete(expected)
	heap_sort(xs, proc(a, b: string) -> bool {return b < a})

	if !slice.equal(xs, expected) {
		testing.expectf(t, false, "expected %v but got %v\n", expected, xs)
	}
}

