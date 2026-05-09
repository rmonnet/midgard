package midgard

import "base:intrinsics"
import "core:fmt"
import "core:math/rand"
import "core:slice"
import "core:time"

merge_sort_2 :: proc(xs: []$T) where intrinsics.type_is_ordered(T) {

	less :: #force_inline proc(a, b: T) -> bool {
		return a < b
	}
	merge_sort_by(xs, less)
}

main :: proc() {

	xs: [1000]f64
	for i in 0 ..< len(xs) {
		xs[i] = rand.float64()
	}

	ys := slice.clone(xs[:])
	defer delete(ys)
	start := time.now()
	merge_sort(ys)
	elapsed := time.since(start)
	fmt.printf("merge_sort: %v\n", elapsed)

	zs := slice.clone(xs[:])
	defer delete(zs)
	start = time.now()
	merge_sort_2(zs)
	elapsed = time.since(start)
	fmt.printf("merge_sort 2: %v\n", elapsed)


}
