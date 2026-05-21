// This file contains the implementation for the selection sort algorithm.
//
// Selection sort sorts the xs array in place
// by examining each element and swapping it with
// the smallest element on its right.
//
// The sort is not stable.
// Its performance is O(N^2).
package midgard

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
selection_sort :: proc(xs: []$T, cmp: proc(a, b: T) -> Cmp) {

	for i in 0 ..< len(xs) {
		min_j := i
		for j in i + 1 ..< len(xs) {
			if cmp(xs[j], xs[min_j]) == .Less {
				min_j = j
			}
		}
		xs[i], xs[min_j] = xs[min_j], xs[i]
	}
}

