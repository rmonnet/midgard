// This file contains the implementation for the insertion sort algorithm.
//
// Insertion sort sorts the xs array in place by examining each element, considering the elements
// on its left to be in order and moving backward, exchanging the element with the one considered
// as long as the element is smaller than the considered element.
//
// The sort is stable.
// Its performance is O(N^2).
// It can be faster than selection sort
// if the original array is partially sorted.
package midgard

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
insertion_sort :: proc(xs: []$T, cmp: proc(a, b: T) -> Cmp) {

	for i in 0 ..< len(xs) {
		for j := i; j > 0; j -= 1 {
			if cmp(xs[j], xs[j - 1]) != .Less {break}
			xs[j], xs[j - 1] = xs[j - 1], xs[j]
		}
	}
}

