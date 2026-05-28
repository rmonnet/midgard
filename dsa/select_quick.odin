// This files contains the implementation of Quick Select, an algorithm
// used to select the k-th ranked element of an array without sorting it.
//
// This algorithm uses the same strategy as Quick Sort.
//
// We are assuming that the element type is Totally Ordered and that
// we only need to define the `less_than` procedure to specify all the
// comparison operators for the set.
//
package dsa

// Select the k-th element of the xs slice. Note that this algorithm
// will change the order of the elements in the input slice but not
// in a fully ordered way.
//
quick_select :: proc(xs: []$T, k: int, less_than: proc(a, b: T) -> bool) -> T {

	partition :: proc(xs: []T, lo, hi: int, less_than: proc(a, b: T) -> bool) -> int {

		i := lo
		j := hi + 1
		ref := xs[lo]
		for {
			for {
				i += 1
				if !less_than(xs[i], ref) || (i == hi) {break}
			}
			for {
				j -= 1
				if !less_than(ref, xs[j]) || (j == lo) {break}
			}
			if i >= j {break}
			xs[i], xs[j] = xs[j], xs[i]
		}
		xs[lo], xs[j] = xs[j], xs[lo]
		return j
	}

	// Make sure the array is randomized to avoid being in the worse case for performance.
	shuffle(xs)
	lo := 0
	hi := len(xs) - 1
	for hi > lo {
		j := partition(xs, lo, hi, less_than)
		switch {
		case j < k:
			lo = j + 1
		case j > k:
			hi = j - 1
		case:
			return xs[k]
		}
	}
	return xs[k]
}

// Tests
// -----

import "core:testing"

@(test)
qs_test_quick_select :: proc(t: ^testing.T) {

	quick_select_int :: proc(xs: []int, k: int) -> int {

		less_than :: proc(a, b: int) -> bool {return a < b}

		return quick_select(xs, k, less_than)
	}

	xs := []int{17, 5, 20, 1, 12, 10, 18, 3, 9, 16, 2, 13, 14, 8, 7, 6, 4, 12, 2, 19, 15, 11}
	// the sorted array:
	// {1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20}

	testing.expect_value(t, quick_select_int(xs, 0), 1)
	testing.expect_value(t, quick_select_int(xs, 21), 20)
	testing.expect_value(t, quick_select_int(xs, 10), 10)
}

