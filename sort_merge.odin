// This file contains the implementation for the merge sort algorithm.
//
// Merge sort sorts the xs array by recursively dividing the array
// into two sub-arrays, sorting them and merging them back into the main
// array.
//
// Merge sort requires a secondary array to temporarily hold the sorted
// sub-arrays during the merge phase but the temporary array can be
// reused between the recursive calls.
//
// The sort is stable.
// It is an O(N . lgN) algorithm but it requires N additional cells
// for the auxiliary array.
package midgard

// Sort the xs slice in place, using the `cmp()` procedure
//  parameter to compare elements.
merge_sort :: proc(xs: []$T, cmp: proc(a, b: T) -> Cmp) {

	// The lower boundary size under which we use
	// insertion sort instead as an optimization.
	// This cuts off the number of recursive calls to merge_sort.
	CUTOFF :: 7

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

	sort :: proc(xs: []$T, aux: []T, lo: int, hi: int, cmp: proc(a, b: T) -> Cmp) {

		// Optimization: If the array is small use insertion sort since
		// it has less overhead.
		if (hi - lo + 1) <= CUTOFF {
			insertion_sort(xs[lo:hi + 1], cmp)
			return
		}

		mid := lo + (hi - lo) / 2
		sort(xs, aux, lo, mid, cmp)
		sort(xs, aux, mid + 1, hi, cmp)
		if cmp(xs[mid + 1], xs[mid]) != .Less {return}
		merge(xs, aux, lo, mid, hi, cmp)
	}


	aux := make([]T, len(xs))
	defer delete(aux)
	sort(xs, aux, 0, len(xs) - 1, cmp)
}

