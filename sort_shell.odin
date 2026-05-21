// This file contains the implementation for the shell sort algorithm.
//
// Shell sort sorts the xs array as an h array
// (that is considering only the h-th elements of the array)
// using insertion sort. It then continues to do so while
// decreasing the value of h down to 1.
//
// The sort is not stable.
// This is efficient because 1) the h-array stays sorted as we decrease
// the value of h and 2) insertion sort is efficient when used with partially
// sorted arrays.
package midgard

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
shell_sort :: proc(xs: []$T, cmp: proc(a, b: T) -> Cmp) {

	h := 1
	for h < len(xs) / 3 {
		h = 3 * h + 1
	}
	for ; h >= 1; h = h / 3 {
		for i := h; i < len(xs); i += 1 {
			for j := i; j >= h; j -= h {
				if cmp(xs[j], xs[j - h]) != .Less {break}
				xs[j], xs[j - h] = xs[j - h], xs[j]
			}
		}
	}
}

