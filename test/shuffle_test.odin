package test

import alg ".."
import "core:slice"
import "core:testing"


@(test)
test_shuffle :: proc(t: ^testing.T) {

	xs := fill_int_array(1000)
	ys := slice.clone(xs[:])
	defer delete(ys)
	alg.shuffle(ys)
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

