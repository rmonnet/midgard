// This file contains the implementation for the shuffle algorithm.
package midgard

import rand "core:math/rand"

// This is needed because the compiler doesn't instantiate
// `shuffle()` in this file since it is generic.
_ :: rand.int_max

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

