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

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
bottom_merge_sort :: proc(xs: []$T, cmp: proc(a, b: T) -> Cmp) {

	merge :: proc(xs: []$T, aux: []T, lo: int, mid: int, hi: int, cmp: proc(a, b: T) -> Cmp) {

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
			} else if cmp(aux[j], aux[i]) == .Less {
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
			merge(xs, aux, lo, lo + size - 1, min(lo + 2 * size - 1, len(xs) - 1), cmp)
		}
	}
}

