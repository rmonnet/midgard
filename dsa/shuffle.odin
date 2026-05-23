// This file contains an implementation for the shuffle algorithm.
// This algorithm randomizes the order of the elements in a slice
// approximating a uniform distribution.
package dsa

import rand "core:math/rand"

// `shuffle` randomizes the elements in the slice.
// It can be thought as the inverse of a sort algorithm.
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

// ------------------------------------------
// Tests
// ------------------------------------------

import "core:slice"
import "core:testing"


@(test)
test_shuffle :: proc(t: ^testing.T) {

	// Fill the array with integers from 1..999, shuffle and test that the elements
	// have moved.
	// TODO: add a test to check that the distribution is uniform.
	xs: [1000]int
	for i in 0 ..< len(xs) {xs[i] = i + 1}
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
	if !slice.equal(xs[:], ys) {
		testing.expectf(t, false, "original elements missing: expected %v but got %v\n", xs, ys)
	}
}

