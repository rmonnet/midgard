// This file contains the implementation for the bottom merge sort algorithm.
//
// Bottom Merge sort sorts the xs array by incrementally sorting
// larger and larger sections of the array using the merge portion
// of the sort algorithm. It starts with a section of size 2 and double
// the size with each iteration until the entire array is covered.
//
// Bottom Merge sort requires a secondary array to temporarily hold the sorted
// sub-arrays during the merge phase but the temporary array can be
// reused between the recursive calls.
//
// The sort is stable.
// It is an O(N . lgN) algorithm but it requires N additional cells
// for the auxiliary array.
package midgard

import "base:intrinsics"
import "core:testing"

// Sort the xs slice in-place.
bottom_merge_sort :: proc(xs: []$T) where intrinsics.type_is_ordered(T) {

	merge :: proc(xs: []$T, aux: []T, lo: int, mid: int, hi: int) {

		copy(aux[lo:hi + 1], xs[lo:hi + 1])
		i := lo
		j := mid + 1
		for k in lo ..= hi {
			if i > mid {
				xs[k] = aux[j]
				j += 1
			} else if j > hi {
				xs[k] = aux[i]
				i += 1
			} else if aux[j] < aux[i] {
				xs[k] = aux[j]
				j += 1
			} else {
				xs[k] = aux[i]
				i += 1
			}
		}
	}

	aux := make([]T, len(xs))
	defer delete(aux)

	for size := 1; size < len(xs); size *= 2 {
		for lo := 0; lo < len(xs) - size; lo += 2 * size {
			merge(xs, aux, lo, lo + size - 1, min(lo + 2 * size - 1, len(xs) - 1))
		}
	}
}

// Sort the xs slice in place, using the `less()` procedure
//  parameter to compare elements.
bottom_merge_sort_by :: proc(xs: []$T, less: proc(a, b: T) -> bool) {

	merge :: proc(xs: []$T, aux: []T, lo: int, mid: int, hi: int, less: proc(a, b: T) -> bool) {

		copy(aux[lo:hi + 1], xs[lo:hi + 1])
		i := lo
		j := mid + 1
		for k in lo ..= hi {
			if i > mid {
				xs[k] = aux[j]
				j += 1
			} else if j > hi {
				xs[k] = aux[i]
				i += 1
			} else if less(aux[j], aux[i]) {
				xs[k] = aux[j]
				j += 1
			} else {
				xs[k] = aux[i]
				i += 1
			}
		}
	}

	aux := make([]T, len(xs))
	defer delete(aux)

	for size := 1; size < len(xs); size *= 2 {
		for lo := 0; lo < len(xs) - size; lo += 2 * size {
			merge(xs, aux, lo, lo + size - 1, min(lo + 2 * size - 1, len(xs) - 1), less)
		}
	}
}

// -----------------------------------------------
// Tests
// -----------------------------------------------

@(test)
test_bottom_merge_sort :: proc(t: ^testing.T) {

	bottom_merge_sort_int :: proc(xs: []int) {bottom_merge_sort(xs)}

	test_sort_int_helper(t, bottom_merge_sort_int)
}

@(test)
test_bottom_merge_sort_large :: proc(t: ^testing.T) {

	bottom_merge_sort_f64 :: proc(xs: []f64) {bottom_merge_sort(xs)}

	test_sort_float_helper(t, bottom_merge_sort_f64)
}

@(test)
test_bottom_merge_sort_by :: proc(t: ^testing.T) {

	bottom_merge_sort_string_by :: proc(xs: []string, less: proc(_, _: string) -> bool) {
		bottom_merge_sort_by(xs, less)
	}

	test_sort_by_string_helper(t, bottom_merge_sort_string_by)
}

@(test)
test_bottom_merge_sort_by_reverse :: proc(t: ^testing.T) {

	bottom_merge_sort_string_by :: proc(xs: []string, less: proc(_, _: string) -> bool) {
		bottom_merge_sort_by(xs, less)
	}

	test_sort_by_string_reverse_helper(t, bottom_merge_sort_string_by)
}

