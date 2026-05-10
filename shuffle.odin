// This file contains the implementation for the shuffle algorithm.
package midgard

import "core:math/rand"
import "core:slice"
import "core:testing"


// Shuffle uniformly shuffle the values in an array.
//
// The resulting random distribution is uniform.
shuffle :: proc(xs: []$T) {

	// Note: randomly exchanging each card with another
	// card in the array doesn't result in a uniform distribution.
	// Exchanging each card with a card to its left does.
	for i in 1 ..< len(xs) {
		j := rand.int_max(i + 1)
		xs[i], xs[j] = xs[j], xs[i]
	}
}

// -----------------------------------------------
// Tests
// -----------------------------------------------

@(test)
test_shuffle :: proc(t: ^testing.T) {

	xs := fill_int_array(1000)
	ys := slice.clone(xs[:])
	defer delete(ys)
	shuffle(ys)
	// We need at least 40% of the elements in a different position
	different := 0
	for i in 0 ..< len(xs) {
		if xs[i] != ys[i] {
			different += 1
		}
	}
	testing.expect(t, different > 400, msg = "At least 40% of elements in the wrong position")
	slice.sort(ys)
	expect_slices(t, ys, xs[:])
}

